# GitHub Actions Configuration

## Required Repository Secrets

Configure these secrets in your repository settings (Settings > Secrets and variables > Actions):

### Environment-Independent Secrets

- `GITHUB_TOKEN` - Automatically provided by GitHub
- `DOCKERHUB_USERNAME` - Docker Hub username for image publishing
- `DOCKERHUB_TOKEN` - Docker Hub access token (not password)
- `AWS_ACCESS_KEY_ID` - AWS access key for infrastructure management
- `AWS_SECRET_ACCESS_KEY` - AWS secret key for infrastructure management
- `REPO_ACCESS_TOKEN` - GitHub personal access token with repo scope for cross-repo operations

### Environment-Specific Secrets

Configure these for each environment (development, staging, production):

- `RAILWAY_TOKEN` - Railway deployment token
- `DB_HOST` - Database hostname
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password

## Environment Configuration

Three environments are configured:

1. Development
   - Automatic deployments from PRs
   - No approval required
   - Branch protection: None

2. Staging
   - Automatic deployments from main branch
   - No approval required
   - Branch protection: main

3. Production
   - Manual deployment trigger only
   - Requires approval from authorized reviewers
   - Branch protection: main
   - Wait timer: 15 minutes

## Repository Variables

Configure these variables in repository settings:

- `AWS_REGION` (default: us-west-2)
- `DOCKER_REGISTRY` (default: docker.io)
- `ORGANIZATION` (default: spectra)
