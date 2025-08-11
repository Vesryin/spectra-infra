#!/bin/bash
# Spectra AI Deployment Script
# Usage: ./deploy.sh [environment]

set -e

# Default to development if no environment is specified
ENVIRONMENT=${1:-development}
VALID_ENVIRONMENTS=("development" "staging" "production")

# Validate environment
if [[ ! " ${VALID_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
    echo "Error: Invalid environment. Please use one of: ${VALID_ENVIRONMENTS[*]}"
    exit 1
fi

echo "Deploying to ${ENVIRONMENT} environment..."

# Load environment variables
if [ -f ".env.${ENVIRONMENT}" ]; then
    echo "Loading environment variables from .env.${ENVIRONMENT}..."
    export $(grep -v '^#' .env.${ENVIRONMENT} | xargs)
else
    echo "Warning: .env.${ENVIRONMENT} file not found"
fi

# Build Docker image
echo "Building Docker image..."
docker build -t spectra/service:latest -f docker/service/Dockerfile .

# Push to Docker registry if not local development
if [ "$ENVIRONMENT" != "development" ]; then
    echo "Pushing Docker image to registry..."
    docker push spectra/service:latest
fi

# Deploy based on environment
case $ENVIRONMENT in
    development)
        echo "Starting local development environment..."
        docker-compose -f docker/docker-compose.yml up -d
        ;;
    staging)
        echo "Deploying to Railway staging environment..."
        railway up --environment staging
        ;;
    production)
        echo "Deploying to Railway production environment..."
        railway up --environment production
        ;;
esac

echo "Deployment to ${ENVIRONMENT} completed successfully!"
