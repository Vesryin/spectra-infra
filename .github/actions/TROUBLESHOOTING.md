# GitHub Actions Troubleshooting Guide

## Common Issues and Solutions

### 1. Workflow Permission Errors

#### Symptoms
- "Resource not accessible by integration" error
- "Permission denied" in workflow logs
- Failed repository dispatch events

#### Solutions
1. Check repository settings:
   ```bash
   gh api repos/:owner/:repo/actions/permissions
   ```
2. Enable required permissions:
   - Settings > Actions > General
   - Workflow permissions: "Read and write permissions"
   - Allow GitHub Actions to create and approve pull requests

#### Prevention
- Regularly audit workflow permissions
- Use dedicated service accounts where possible
- Follow principle of least privilege

### 2. Docker Image Push Failures

#### Symptoms
- "unauthorized: authentication required" error
- "denied: requested access to the resource is denied"
- Docker login failures

#### Solutions
1. Verify Docker Hub credentials:
   ```bash
   gh secret list | grep DOCKERHUB
   ```
2. Test Docker login locally:
   ```bash
   docker login -u $DOCKERHUB_USERNAME
   ```
3. Check organization access:
   ```bash
   docker pull $ORGANIZATION/test:latest
   ```

#### Prevention
- Rotate Docker Hub tokens regularly
- Use separate tokens for different environments
- Implement token expiration monitoring

### 3. AWS Authentication Issues

#### Symptoms
- "Unable to locate credentials" in AWS CLI
- "AccessDenied" when accessing AWS services
- EKS connection failures

#### Solutions
1. Verify AWS credentials:
   ```bash
   gh secret list | grep AWS
   ```
2. Check IAM permissions:
   ```bash
   aws sts get-caller-identity
   ```
3. Test EKS access:
   ```bash
   aws eks get-token --cluster-name spectra-staging
   ```

#### Prevention
- Use AWS IAM roles where possible
- Implement credential rotation
- Monitor IAM policy changes

### 4. Environment Deployment Failures

#### Symptoms
- "Environment not found" error
- Protection rule violations
- Missing environment secrets

#### Solutions
1. Verify environment exists:
   ```bash
   gh api repos/:owner/:repo/environments
   ```
2. Check protection rules:
   ```bash
   gh api repos/:owner/:repo/environments/:environment/deployment-branch-policies
   ```
3. Verify environment secrets:
   ```bash
   gh secret list -e :environment
   ```

#### Prevention
- Regular environment configuration audits
- Automated environment setup testing
- Documentation of protection rules

### 5. Railway Deployment Issues

#### Symptoms
- "Invalid token" in Railway CLI
- Deployment timeouts
- Service startup failures

#### Solutions
1. Verify Railway token:
   ```bash
   railway whoami
   ```
2. Check project linking:
   ```bash
   railway link
   ```
3. Verify environment variables:
   ```bash
   railway variables
   ```

#### Prevention
- Regular token rotation
- Environment-specific Railway projects
- Deployment logs monitoring

### 6. Cross-Repository Communication Failures

#### Symptoms
- Repository dispatch events failing
- Workflow triggers not working
- Missing repository access

#### Solutions
1. Check PAT permissions:
   ```bash
   gh auth status
   ```
2. Verify repository access:
   ```bash
   gh repo view $REPOSITORY
   ```
3. Test repository dispatch:
   ```bash
   gh api repos/:owner/:repo/dispatches
   ```

#### Prevention
- Use fine-grained PATs
- Regular token rotation
- Monitor cross-repo events

### 7. Database Migration Issues

#### Symptoms
- Flyway migration failures
- Database connection timeouts
- Schema version conflicts

#### Solutions
1. Verify database credentials:
   ```bash
   gh secret list -e :environment | grep DB_
   ```
2. Test database connection:
   ```bash
   psql -h $DB_HOST -U $DB_USER -d spectra
   ```
3. Check migration history:
   ```bash
   flyway info
   ```

#### Prevention
- Migration dry runs
- Database backup before migrations
- Version control for migrations

### 8. Cache and Performance Issues

#### Symptoms
- Slow workflow execution
- High build times
- Cache miss rates

#### Solutions
1. Check cache hit rates:
   ```bash
   gh run view --log-failed
   ```
2. Optimize cache keys:
   ```yaml
   cache:
     key: ${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
   ```
3. Monitor build times:
   ```bash
   gh run list --json durationMs
   ```

#### Prevention
- Regular cache cleanup
- Optimize Dockerfile layers
- Monitor workflow metrics

## Diagnostic Tools

### GitHub CLI Commands
```bash
# List workflow runs
gh run list

# View workflow details
gh run view $RUN_ID

# Download workflow logs
gh run download $RUN_ID

# List repository secrets
gh secret list

# List environment variables
gh variable list
```

### Docker Commands
```bash
# Test image build
docker build --progress=plain .

# Check image layers
docker history $IMAGE_NAME

# Test registry access
docker pull $REGISTRY/$IMAGE_NAME
```

### AWS Commands
```bash
# Check AWS identity
aws sts get-caller-identity

# Test EKS access
aws eks list-clusters

# Verify kubeconfig
aws eks update-kubeconfig
```

## Monitoring and Alerts

### 1. Set up workflow notifications
```yaml
on:
  workflow_run:
    workflows: ["CI", "CD"]
    types: [completed]
```

### 2. Configure status checks
```yaml
jobs:
  notify:
    if: always()
    runs-on: ubuntu-latest
    steps:
      - uses: 8398a7/action-slack@v3
```

### 3. Implement failure alerts
```yaml
- name: Send alert
  if: failure()
  uses: actions/github-script@v6
```

## Recovery Procedures

### 1. Workflow Failure
1. Check workflow logs
2. Identify failure point
3. Fix underlying issue
4. Re-run workflow

### 2. Environment Recovery
1. Verify environment state
2. Check protection rules
3. Reset environment if needed
4. Re-deploy services

### 3. Secret Recovery
1. Rotate compromised secrets
2. Update environment
3. Verify new secrets
4. Re-run affected workflows
