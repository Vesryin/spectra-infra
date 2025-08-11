# GitHub Actions Setup Guide

## 1. Environment Setup

### Development Environment
1. Go to repository Settings > Environments
2. Click "New environment"
3. Name: `development`
4. Configure environment protection rules:
   ```yaml
   Deployment branches:
     - Allow all branches
   Required reviewers: none
   Wait timer: none
   ```
5. Add environment secrets:
   - `RAILWAY_TOKEN`
   - `DB_HOST`
   - `DB_USER`
   - `DB_PASSWORD`

### Staging Environment
1. Go to repository Settings > Environments
2. Click "New environment"
3. Name: `staging`
4. Configure environment protection rules:
   ```yaml
   Deployment branches:
     - Protected branches only
     - main
   Required reviewers: none
   Wait timer: none
   ```
5. Add environment secrets:
   - `RAILWAY_TOKEN`
   - `DB_HOST`
   - `DB_USER`
   - `DB_PASSWORD`

### Production Environment
1. Go to repository Settings > Environments
2. Click "New environment"
3. Name: `production`
4. Configure environment protection rules:
   ```yaml
   Deployment branches:
     - Protected branches only
     - main
   Required reviewers:
     - Add at least 2 team members with write access
   Wait timer: 15 minutes
   ```
5. Add environment secrets:
   - `RAILWAY_TOKEN`
   - `DB_HOST`
   - `DB_USER`
   - `DB_PASSWORD`

## 2. Repository Secrets Setup

1. Go to repository Settings > Secrets and variables > Actions
2. Add repository secrets:
   ```yaml
   DOCKERHUB_USERNAME:
     Value: your_dockerhub_username
     Description: Docker Hub username for image publishing
   
   DOCKERHUB_TOKEN:
     Value: your_dockerhub_token
     Description: Docker Hub access token (not password)
   
   AWS_ACCESS_KEY_ID:
     Value: your_aws_access_key
     Description: AWS access key for infrastructure management
   
   AWS_SECRET_ACCESS_KEY:
     Value: your_aws_secret_key
     Description: AWS secret key for infrastructure management
   
   REPO_ACCESS_TOKEN:
     Value: your_github_pat
     Description: GitHub personal access token with repo scope
   ```

## 3. Repository Variables Setup

1. Go to repository Settings > Secrets and variables > Actions
2. Click on "Variables" tab
3. Add repository variables:
   ```yaml
   AWS_REGION:
     Value: us-west-2
     Description: Default AWS region for deployments
   
   DOCKER_REGISTRY:
     Value: docker.io
     Description: Docker registry URL
   
   ORGANIZATION:
     Value: spectra
     Description: Organization name for Docker images
   ```

## 4. Branch Protection Rules

1. Go to repository Settings > Branches
2. Click "Add branch protection rule"
3. Configure for `main` branch:
   ```yaml
   Branch name pattern: main
   Protect matching branches:
     - Require a pull request before merging
     - Require approvals (2)
     - Dismiss stale pull request approvals
     - Require status checks to pass
     - Require branches to be up to date
     - Include administrators
   Status checks required:
     - ci (from CI workflow)
     - test (from CI workflow)
   ```

## 5. GitHub Actions Permissions

1. Go to repository Settings > Actions > General
2. Under "Workflow permissions":
   - Enable "Read and write permissions"
   - Enable "Allow GitHub Actions to create and approve pull requests"

## 6. Railway CLI Setup

1. Install Railway CLI:
   ```bash
   npm install -g @railway/cli
   ```
2. Generate Railway token:
   - Go to Railway Dashboard
   - Settings > Access Tokens
   - Generate new token
   - Add token to each environment's secrets

## 7. Docker Hub Setup

1. Create access token:
   - Go to Docker Hub > Account Settings > Security
   - New Access Token
   - Give it a descriptive name
   - Copy token and add to repository secrets

## 8. AWS IAM Setup

1. Create IAM user:
   - Go to AWS Console > IAM
   - Create new user for CI/CD
   - Attach policies:
     - AWSEKSClusterPolicy
     - AWSEKSServicePolicy
     - EC2ContainerRegistryFullAccess
2. Generate access keys:
   - Under Security credentials
   - Create access key
   - Add to repository secrets

## 9. Verification Steps

1. Check environments:
   ```bash
   gh api repos/:owner/:repo/environments
   ```

2. Check secrets (will only show names, not values):
   ```bash
   gh api repos/:owner/:repo/actions/secrets
   ```

3. Check variables:
   ```bash
   gh api repos/:owner/:repo/actions/variables
   ```

4. Verify workflow permissions:
   ```bash
   gh api repos/:owner/:repo/actions/permissions
   ```

## 10. Testing the Setup

1. Create test branch:
   ```bash
   git checkout -b test/workflow-setup
   ```

2. Make a small change:
   ```bash
   echo "# Test change" >> README.md
   ```

3. Push and create PR:
   ```bash
   git add README.md
   git commit -m "test: verify workflow setup"
   git push origin test/workflow-setup
   gh pr create --title "test: verify workflow setup" --body "Testing CI/CD setup"
   ```

4. Monitor workflow runs:
   ```bash
   gh run list --limit 5
   ```

## Troubleshooting

### Common Issues and Solutions

1. "Context access might be invalid":
   - This is a warning, not an error
   - Verify secret exists in correct scope (repo or environment)

2. Workflow permission errors:
   - Check "Workflow permissions" in repository settings
   - Verify PAT has correct scopes

3. Docker push fails:
   - Verify DOCKERHUB_USERNAME and DOCKERHUB_TOKEN
   - Check Docker Hub organization access

4. AWS authentication fails:
   - Verify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
   - Check IAM user permissions

5. Railway deployment fails:
   - Verify RAILWAY_TOKEN in environment secrets
   - Check Railway project permissions

### Support Resources

- GitHub Actions documentation: https://docs.github.com/en/actions
- Railway CLI documentation: https://docs.railway.app/cli
- Docker Hub documentation: https://docs.docker.com/docker-hub/
- AWS EKS documentation: https://docs.aws.amazon.com/eks/

### Maintenance

- Rotate secrets every 90 days
- Review environment protection rules quarterly
- Update workflow files when adding new services
- Keep documentation in sync with changes
