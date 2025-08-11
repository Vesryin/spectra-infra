#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Comprehensive setup script for Spectra infrastructure
.DESCRIPTION
    Sets up complete infrastructure including multi-region support,
    security configurations, monitoring, and compliance features.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('development', 'staging', 'production')]
    [string]$Environment,

    [Parameter(Mandatory=$true)]
    [string[]]$Regions,

    [Parameter(Mandatory=$false)]
    [switch]$EnableCompliance,

    [Parameter(Mandatory=$false)]
    [switch]$EnableMultiRegion,

    [Parameter(Mandatory=$false)]
    [switch]$EnableAirGapped,

    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = '.github/environments'
)

# Import required modules
Import-Module .\SpectraGitHubActions.psm1

# Initialize logging
$logFile = "setup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $logFile

function Install-PreRequisites {
    Write-Host "Installing prerequisites..."
    
    # Check for required tools
    $tools = @{
        'git' = 'Git'
        'docker' = 'Docker'
        'kubectl' = 'Kubernetes CLI'
        'aws' = 'AWS CLI'
        'helm' = 'Helm'
        'gh' = 'GitHub CLI'
    }

    foreach ($tool in $tools.Keys) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Error "Required tool $($tools[$tool]) is not installed"
            exit 1
        }
    }
}

function Set-AWSConfiguration {
    param(
        [string]$Region,
        [string]$Environment
    )

    Write-Host "Configuring AWS for region $Region..."

    # Set AWS credentials
    $env:AWS_ACCESS_KEY_ID = Read-Host "Enter AWS Access Key ID"
    $env:AWS_SECRET_ACCESS_KEY = Read-Host "Enter AWS Secret Access Key"
    
    # Configure AWS CLI
    aws configure set region $Region
    aws configure set output json
}

function Initialize-GitHubEnvironment {
    param(
        [string]$Environment
    )

    Write-Host "Initializing GitHub environment $Environment..."

    # Set up environment protection rules
    $protectionRules = @{
        wait_timer = 0
        reviewers = $null
        deployment_branch_policy = @{
            protected_branches = $true
            custom_branch_policies = $false
        }
    }
    $protectionJson = $protectionRules | ConvertTo-Json
    gh api --method PUT "/repos/:owner/:repo/environments/$Environment" -f $protectionJson

    # Set up environment secrets
    $secrets = @(
        'AWS_ACCESS_KEY_ID',
        'AWS_SECRET_ACCESS_KEY',
        'DOCKER_USERNAME',
        'DOCKER_PASSWORD',
        'DATABASE_URL',
        'API_KEY'
    )

    foreach ($secret in $secrets) {
        $value = Read-Host "Enter value for secret '$secret' in $Environment"
        gh secret set $secret --env $Environment --body $value
    }
}

function Set-ComplianceMode {
    param(
        [string]$Environment
    )

    Write-Host "Enabling compliance mode for $Environment..."

    # Configure HIPAA compliance settings
    $hipaaConfig = @{
        encryption = @{
            atRest = $true
            inTransit = $true
        }
        audit = @{
            enabled = $true
            retention = "6y"
        }
    }

    # Configure SOC2 compliance settings
    $soc2Config = @{
        monitoring = @{
            auditLogs = @{
                enabled = $true
                destinations = @("cloudwatch", "s3")
            }
        }
    }

    # Apply compliance configurations
    $config = Get-Content (Join-Path $ConfigPath "$Environment.yaml") | ConvertFrom-Yaml
    $config.compliance = @{
        hipaa = $hipaaConfig
        soc2 = $soc2Config
    }
    $config | ConvertTo-Yaml | Set-Content (Join-Path $ConfigPath "$Environment.yaml")
}

function Initialize-Monitoring {
    param(
        [string]$Environment
    )

    Write-Host "Setting up monitoring for $Environment..."

    # Deploy Prometheus and Grafana
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    # Install Prometheus Operator
    helm install prometheus prometheus-community/kube-prometheus-stack `
        --namespace monitoring `
        --create-namespace `
        --values monitoring/prometheus-values.yaml

    # Configure alert rules
    kubectl apply -f monitoring/alert-rules.yaml

    # Set up logging
    helm repo add elastic https://helm.elastic.co
    helm install elasticsearch elastic/elasticsearch `
        --namespace logging `
        --create-namespace `
        --values logging/elasticsearch-values.yaml

    helm install fluent-bit stable/fluent-bit `
        --namespace logging `
        --values logging/fluent-bit-values.yaml
}

function Initialize-Security {
    param(
        [string]$Environment
    )

    Write-Host "Configuring security for $Environment..."

    # Set up network policies
    kubectl apply -f security/network-policies/

    # Configure pod security policies
    kubectl apply -f security/pod-security-policies/

    # Set up secret rotation
    kubectl apply -f security/secret-rotation/

    # Configure RBAC
    kubectl apply -f security/rbac/
}

# Main execution
try {
    Install-PreRequisites

    foreach ($region in $Regions) {
        Set-AWSConfiguration -Region $region -Environment $Environment
        Initialize-SpectraEnvironment -Environment $Environment -AWSRegion $region
    }

    Initialize-GitHubEnvironment -Environment $Environment

    if ($EnableCompliance) {
        Set-ComplianceMode -Environment $Environment
    }

    if ($EnableMultiRegion) {
        # Set up Route 53 for multi-region
        aws route53 create-health-check --caller-reference (New-Guid).Guid `
            --health-check-config @{
                Type = "HTTPS"
                FullyQualifiedDomainName = "$Environment.spectra.internal"
                Port = 443
                ResourcePath = "/health"
                RequestInterval = 30
                FailureThreshold = 3
            }
    }

    Initialize-Monitoring -Environment $Environment
    Initialize-Security -Environment $Environment

    Write-Host "Setup completed successfully for environment $Environment"
    Write-Host "Log file: $logFile"
}
catch {
    Write-Error "Setup failed: $_"
    Write-Host "Check log file for details: $logFile"
    exit 1
}
finally {
    Stop-Transcript
}
