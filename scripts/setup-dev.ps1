# PowerShell script for setting up the development environment
# Usage: .\setup-dev.ps1

# Check for required tools
$requiredTools = @("git", "docker", "npm", "railway")

Write-Host "Checking for required tools..." -ForegroundColor Cyan

foreach ($tool in $requiredTools) {
    try {
        $toolPath = Get-Command $tool -ErrorAction Stop
        Write-Host "✓ $tool found at: $($toolPath.Path)" -ForegroundColor Green
    } catch {
        Write-Host "✗ $tool not found. Please install it and try again." -ForegroundColor Red
        Write-Host "  See the README.md for installation instructions." -ForegroundColor Yellow
        exit 1
    }
}

# Create environment file if it doesn't exist
$envFile = ".env.development"
if (-not (Test-Path $envFile)) {
    Write-Host "Creating development environment file..." -ForegroundColor Cyan
    Copy-Item "secrets/.env.template" $envFile
    Write-Host "Please update $envFile with your development settings." -ForegroundColor Yellow
}

# Setup Docker environment
Write-Host "Setting up Docker development environment..." -ForegroundColor Cyan
docker-compose -f docker/docker-compose.yml build

Write-Host "Development environment setup complete!" -ForegroundColor Green
Write-Host "To start the development environment, run: docker-compose -f docker/docker-compose.yml up -d" -ForegroundColor Cyan
