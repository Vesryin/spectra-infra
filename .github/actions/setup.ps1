# Automated GitHub Actions Setup Script

<#
.SYNOPSIS
    Automates the setup of GitHub Actions environments, secrets, and variables for Spectra-Infra.
.DESCRIPTION
    This script uses GitHub CLI to configure environments, secrets, and variables for the repository.
    Requires GitHub CLI (gh) to be installed and authenticated.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoName = "spectra-infra",
    
    [Parameter(Mandatory=$true)]
    [string]$OrgName = "Vesryin",
    
    [Parameter(Mandatory=$false)]
    [string]$AWSRegion = "us-west-2"
)

# Function to check if GitHub CLI is installed and authenticated
function Test-GitHubCLI {
    try {
        $null = gh auth status
        Write-Host "✅ GitHub CLI is authenticated" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ GitHub CLI is not installed or not authenticated" -ForegroundColor Red
        Write-Host "Please install GitHub CLI and run 'gh auth login'" -ForegroundColor Yellow
        return $false
    }
}

# Function to create an environment
function New-GitHubEnvironment {
    param(
        [string]$Name,
        [string]$WaitTimer = "0",
        [array]$Reviewers = @(),
        [bool]$ProtectedBranches = $false
    )
    
    try {
        # Create environment
        $envData = @{
            wait_timer = $WaitTimer
            prevent_self_review = $true
            reviewers = $Reviewers
            deployment_branch_policy = @{
                protected_branches = $ProtectedBranches
                custom_branch_policies = -not $ProtectedBranches
            }
        } | ConvertTo-Json

        $null = gh api --method PUT "/repos/$OrgName/$RepoName/environments/$Name" -f "$envData"
        Write-Host "✅ Created environment: $Name" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to create environment: $Name" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Function to add a secret to an environment
function Add-EnvironmentSecret {
    param(
        [string]$Environment,
        [string]$SecretName,
        [string]$SecretValue
    )
    
    try {
        $null = gh secret set $SecretName --env $Environment --body $SecretValue
        Write-Host "✅ Added secret '$SecretName' to environment '$Environment'" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to add secret '$SecretName' to environment '$Environment'" -ForegroundColor Red
    }
}

# Function to add a repository variable
function Add-RepositoryVariable {
    param(
        [string]$Name,
        [string]$Value
    )
    
    try {
        $null = gh variable set $Name --body $Value
        Write-Host "✅ Added repository variable: $Name" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to add repository variable: $Name" -ForegroundColor Red
    }
}

# Function to set up branch protection
function Set-BranchProtection {
    param(
        [string]$Branch = "main"
    )
    
    try {
        $protectionRules = @{
            required_status_checks = @{
                strict = $true
                checks = @(
                    @{ context = "ci" }
                    @{ context = "test" }
                )
            }
            enforce_admins = $true
            required_pull_request_reviews = @{
                dismissal_restrictions = @{}
                dismiss_stale_reviews = $true
                require_code_owner_reviews = $true
                required_approving_review_count = 2
            }
            restrictions = $null
        } | ConvertTo-Json -Depth 10

        $null = gh api --method PUT "/repos/$OrgName/$RepoName/branches/$Branch/protection" -f "$protectionRules"
        Write-Host "✅ Set up branch protection for: $Branch" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to set up branch protection for: $Branch" -ForegroundColor Red
    }
}

# Main setup process
if (-not (Test-GitHubCLI)) {
    exit 1
}

# 1. Create environments
Write-Host "`n📦 Creating environments..." -ForegroundColor Cyan
New-GitHubEnvironment -Name "development"
New-GitHubEnvironment -Name "staging" -ProtectedBranches $true
New-GitHubEnvironment -Name "production" -WaitTimer "900" -ProtectedBranches $true -Reviewers @("devops-team")

# 2. Set repository variables
Write-Host "`n📝 Setting repository variables..." -ForegroundColor Cyan
Add-RepositoryVariable -Name "AWS_REGION" -Value $AWSRegion
Add-RepositoryVariable -Name "DOCKER_REGISTRY" -Value "docker.io"
Add-RepositoryVariable -Name "ORGANIZATION" -Value $OrgName

# 3. Set up branch protection
Write-Host "`n🔒 Setting up branch protection..." -ForegroundColor Cyan
Set-BranchProtection -Branch "main"

# 4. Prompt for secrets
Write-Host "`n🔑 Please enter the following secrets:" -ForegroundColor Cyan

$environments = @("development", "staging", "production")
$envSecrets = @("RAILWAY_TOKEN", "DB_HOST", "DB_USER", "DB_PASSWORD")
$repoSecrets = @("DOCKERHUB_USERNAME", "DOCKERHUB_TOKEN", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "REPO_ACCESS_TOKEN")

# Set repository-level secrets
foreach ($secret in $repoSecrets) {
    $value = Read-Host "Enter value for repository secret '$secret' (press Enter to skip)"
    if ($value) {
        $null = gh secret set $secret --body $value
        Write-Host "✅ Added repository secret: $secret" -ForegroundColor Green
    }
}

# Set environment-specific secrets
foreach ($env in $environments) {
    Write-Host "`nEnter secrets for $env environment:" -ForegroundColor Yellow
    foreach ($secret in $envSecrets) {
        $value = Read-Host "Enter value for '$secret' in $env (press Enter to skip)"
        if ($value) {
            Add-EnvironmentSecret -Environment $env -SecretName $secret -SecretValue $value
        }
    }
}

Write-Host "`n✨ Setup complete!" -ForegroundColor Green
Write-Host "Please verify the configuration in GitHub repository settings."
