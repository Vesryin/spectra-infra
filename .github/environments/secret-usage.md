# Secret Usage Documentation

This document tracks where each secret is used in our workflows for auditing and maintenance purposes.

## Repository Secrets

| Secret Name | Used In Workflows | Purpose | Last Verified |
|------------|------------------|---------|---------------|
| DOCKERHUB_USERNAME | ci.yml | Docker image publishing | 2025-08-11 |
| DOCKERHUB_TOKEN | ci.yml | Docker image publishing | 2025-08-11 |
| AWS_ACCESS_KEY_ID | setup-environment.yml, repo-sync.yml | AWS infrastructure management | 2025-08-11 |
| AWS_SECRET_ACCESS_KEY | setup-environment.yml, repo-sync.yml | AWS infrastructure management | 2025-08-11 |
| RAILWAY_TOKEN | deploy-railway.yml | Railway deployments | 2025-08-11 |
| DB_HOST | setup-environment.yml | Database connections | 2025-08-11 |
| DB_USER | setup-environment.yml | Database connections | 2025-08-11 |
| DB_PASSWORD | setup-environment.yml | Database connections | 2025-08-11 |
| REPO_ACCESS_TOKEN | setup-environment.yml, repo-sync.yml | Cross-repo operations | 2025-08-11 |

## Environment Secrets

### Development
- RAILWAY_TOKEN
- DB_HOST
- DB_USER
- DB_PASSWORD

### Staging
- RAILWAY_TOKEN
- DB_HOST
- DB_USER
- DB_PASSWORD

### Production
- RAILWAY_TOKEN
- DB_HOST
- DB_USER
- DB_PASSWORD

## Secret Rotation Schedule

- AWS credentials: Every 90 days
- Database credentials: Every 60 days
- Docker Hub token: Every 180 days
- Repository access token: Every 90 days
- Railway token: Every 180 days
