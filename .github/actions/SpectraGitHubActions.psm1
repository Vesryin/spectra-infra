# GitHub Actions Automation Module

<#
.SYNOPSIS
    PowerShell module for automating GitHub Actions setup and maintenance.
.DESCRIPTION
    Provides functions for managing GitHub Actions environments, secrets, workflows, and configurations.
#>

# Module metadata
@{
    ModuleVersion = '1.0.0'
    Author = 'Spectra DevOps'
    Description = 'GitHub Actions automation module'
    PowerShellVersion = '5.1'
}

function Initialize-SpectraEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('development', 'staging', 'production')]
        [string]$Environment,

        [Parameter(Mandatory=$true)]
        [string]$AWSRegion,

        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = '.github/environments'
    )

    begin {
        $ErrorActionPreference = 'Stop'
        Write-Verbose "Initializing $Environment environment"
    }

    process {
        try {
            # Load environment config
            $configFile = Join-Path $ConfigPath "$Environment.yaml"
            $config = Get-Content $configFile | ConvertFrom-Yaml

            # Set up AWS resources
            Initialize-AWSInfrastructure -Region $AWSRegion -Environment $Environment

            # Set up Kubernetes namespace
            Initialize-KubernetesNamespace -Environment $Environment

            # Configure monitoring
            Set-MonitoringConfiguration -Environment $Environment -Config $config.monitoring

            # Set up secrets
            foreach ($secret in $config.secrets) {
                $value = Read-Host "Enter value for secret '$secret' in $Environment (press Enter to skip)"
                if ($value) {
                    Set-EnvironmentSecret -Environment $Environment -Name $secret -Value $value
                }
            }

            # Configure protection rules
            Set-EnvironmentProtection -Environment $Environment -Rules $config.protection_rules

            Write-Verbose "Environment $Environment initialized successfully"
        }
        catch {
            Write-Error "Failed to initialize environment: $_"
            throw
        }
    }
}

function Initialize-AWSInfrastructure {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Region,

        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    process {
        try {
            # Set AWS credentials
            Set-AWSCredentials -AccessKey (Get-Secret 'AWS_ACCESS_KEY_ID') -SecretKey (Get-Secret 'AWS_SECRET_ACCESS_KEY')

            # Create EKS cluster if not exists
            $clusterName = "spectra-$Environment"
            if (-not (Get-EKSCluster -ClusterName $clusterName -Region $Region)) {
                New-EKSCluster -ClusterName $clusterName -Region $Region
            }

            # Set up VPC
            $vpcConfig = @{
                CidrBlock = "10.0.0.0/16"
                Environment = $Environment
                Region = $Region
            }
            Initialize-NetworkInfrastructure @vpcConfig

            # Configure IAM roles
            Set-IAMConfiguration -Environment $Environment

            Write-Verbose "AWS infrastructure initialized for $Environment"
        }
        catch {
            Write-Error "Failed to initialize AWS infrastructure: $_"
            throw
        }
    }
}

function Initialize-KubernetesNamespace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    process {
        try {
            $namespace = "spectra-$Environment"
            
            # Create namespace
            $namespaceYaml = @"
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace
  labels:
    environment: $Environment
"@
            $namespaceYaml | kubectl apply -f -

            # Set resource quotas
            $quotaYaml = @"
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: $namespace
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
"@
            $quotaYaml | kubectl apply -f -

            Write-Verbose "Kubernetes namespace $namespace initialized"
        }
        catch {
            Write-Error "Failed to initialize Kubernetes namespace: $_"
            throw
        }
    }
}

function Set-MonitoringConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Environment,

        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    process {
        try {
            # Deploy Prometheus
            $prometheusValues = @{
                retention = $Config.metrics_retention
                alertmanager = @{
                    enabled = $Config.alerts
                }
            }
            Install-PrometheusStack @prometheusValues

            # Configure logging
            $loggingConfig = @{
                level = $Config.log_level
                retention = "30d"
                elasticsearch = @{
                    replicas = 3
                }
            }
            Set-LoggingInfrastructure @loggingConfig

            Write-Verbose "Monitoring configured for $Environment"
        }
        catch {
            Write-Error "Failed to configure monitoring: $_"
            throw
        }
    }
}

function Set-EnvironmentProtection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Environment,

        [Parameter(Mandatory=$true)]
        [hashtable]$Rules
    )

    process {
        try {
            $protectionConfig = @{
                required_status_checks = @{
                    strict = $true
                    contexts = @("ci/test", "ci/build")
                }
                enforce_admins = $true
                required_pull_request_reviews = @{
                    required_approving_review_count = 2
                    dismiss_stale_reviews = $true
                    require_code_owner_reviews = $true
                }
                restrictions = $null
            }

            if ($Rules.required_reviewers) {
                $protectionConfig.required_pull_request_reviews.required_reviewers = $Rules.required_reviewers
            }

            if ($Rules.wait_timer -gt 0) {
                $protectionConfig.wait_timer = $Rules.wait_timer
            }

            $protectionJson = $protectionConfig | ConvertTo-Json -Depth 10
            gh api --method PUT "/repos/:owner/:repo/environments/$Environment/protection-rules" -f $protectionJson

            Write-Verbose "Protection rules set for $Environment"
        }
        catch {
            Write-Error "Failed to set protection rules: $_"
            throw
        }
    }
}

function Test-EnvironmentConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    process {
        try {
            # Test AWS connectivity
            Test-AWSConnection

            # Test Kubernetes connectivity
            Test-KubernetesConnection -Namespace "spectra-$Environment"

            # Test monitoring
            Test-MonitoringStack

            # Test environment protection
            Test-ProtectionRules -Environment $Environment

            Write-Verbose "All tests passed for $Environment"
        }
        catch {
            Write-Error "Environment tests failed: $_"
            throw
        }
    }
}

function Repair-EnvironmentConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    process {
        try {
            # Check and repair AWS resources
            Repair-AWSResources -Environment $Environment

            # Check and repair Kubernetes resources
            Repair-KubernetesResources -Environment $Environment

            # Check and repair monitoring
            Repair-MonitoringStack -Environment $Environment

            Write-Verbose "Environment $Environment repaired successfully"
        }
        catch {
            Write-Error "Failed to repair environment: $_"
            throw
        }
    }
}

Export-ModuleMember -Function @(
    'Initialize-SpectraEnvironment',
    'Test-EnvironmentConfiguration',
    'Repair-EnvironmentConfiguration'
)
