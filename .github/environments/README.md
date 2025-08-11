# GitHub Actions Environments

This directory contains environment configuration for GitHub Actions workflows.

## Required Secrets

### Docker Hub Access
- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token (not password)

### AWS Access
- `AWS_ACCESS_KEY_ID` - AWS access key ID
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key
- `AWS_REGION` - AWS region (default: us-west-2)

### Database Access
- `DB_HOST` - Database hostname
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password

### Repository Access
- `REPO_ACCESS_TOKEN` - GitHub personal access token with repo scope

### Deployment
- `RAILWAY_TOKEN` - Railway deployment token
- `VERCEL_TOKEN` - Vercel deployment token

## Environment Setup

1. Go to repository Settings > Environments
2. Create three environments: `development`, `staging`, and `production`
3. For each environment, add the required secrets
4. Set up environment protection rules as needed:
   - Required reviewers for production
   - Deployment branch restrictions
   - Wait timer for production deployments
