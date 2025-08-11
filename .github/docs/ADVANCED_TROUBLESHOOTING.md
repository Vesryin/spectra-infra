# Advanced Troubleshooting Guide

## Table of Contents
- [Common Issues](#common-issues)
  - [Infrastructure](#infrastructure)
  - [CI/CD](#cicd)
  - [Cross-Repo Integration](#cross-repo-integration)
  - [Security](#security)
- [Diagnostic Procedures](#diagnostic-procedures)
- [Recovery Procedures](#recovery-procedures)
- [Preventive Measures](#preventive-measures)

## Common Issues

### Infrastructure

#### AWS EKS Cluster Issues
```powershell
# Check cluster health
kubectl get nodes
kubectl describe node <node-name>
```

**Symptoms:**
- Nodes not ready
- Pod scheduling failures
- Resource constraints

**Solutions:**
1. Verify AWS credentials and permissions
2. Check node resource utilization
3. Review cluster autoscaling configuration
4. Validate security groups and VPC settings

#### Docker Image Build Failures
```powershell
# Clean Docker cache
docker system prune -a
```

**Common Causes:**
- Base image not found
- Dependencies installation failure
- Resource limits reached
- Network connectivity issues

### CI/CD

#### GitHub Actions Workflow Failures

**Error:** `Resource not accessible by integration`
```yaml
# Fix by adding permissions
permissions:
  contents: read
  pull-requests: write
```

**Error:** `No space left on device`
```yaml
# Add cleanup step
- name: Cleanup
  run: |
    df -h
    docker system prune -af
    npm cache clean --force
```

### Cross-Repo Integration

#### Repository Dispatch Failures

**Symptoms:**
- Webhook delivery failures
- Authentication errors
- Missing permissions

**Solutions:**
1. Verify PAT token permissions
2. Check repository webhook settings
3. Validate event payload format
4. Review network connectivity

### Security

#### Secret Management Issues

**Common Problems:**
- Secret rotation failures
- Environment variable conflicts
- Missing required secrets
- Invalid secret format

**Solutions:**
1. Use `Initialize-SpectraEnvironment` with `-Verbose`
2. Review secret audit logs
3. Validate secret naming conventions
4. Check environment protection rules

## Diagnostic Procedures

### 1. Infrastructure Health Check
```powershell
Import-Module .\SpectraGitHubActions.psm1
Test-EnvironmentConfiguration -Environment production
```

### 2. CI/CD Pipeline Validation
```powershell
# Validate workflow syntax
gh workflow view [workflow-id]

# Check workflow permissions
gh api /repos/:owner/:repo/actions/permissions
```

### 3. Network Connectivity Tests
```powershell
# Test AWS connectivity
Test-NetConnection -ComputerName sts.amazonaws.com -Port 443

# Test Kubernetes API
kubectl get --raw /healthz
```

## Recovery Procedures

### 1. Environment Recovery
```powershell
# Automated recovery
Repair-EnvironmentConfiguration -Environment production

# Manual recovery steps if automated fails
1. Backup current state
2. Reset environment protection rules
3. Redeploy infrastructure components
4. Restore configuration and secrets
```

### 2. Database Recovery
```powershell
# Verify backup status
aws rds describe-db-snapshots

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-snapshot-identifier <snapshot> \
  --db-instance-identifier <instance>
```

### 3. Secret Recovery
```powershell
# Rotate compromised secrets
1. Generate new secrets
2. Update GitHub environment
3. Update dependent services
4. Verify application functionality
```

## Preventive Measures

### 1. Monitoring Setup

Configure alerts for:
- Infrastructure metrics
- Application errors
- Security events
- Cost thresholds

### 2. Backup Procedures

Implement regular backups:
- Database snapshots
- Infrastructure state
- Configuration files
- Secret rotation schedule

### 3. Documentation

Maintain up-to-date:
- Architecture diagrams
- Runbooks
- Security policies
- Recovery procedures

### 4. Testing

Regular testing of:
- Disaster recovery procedures
- Security controls
- Backup restoration
- Cross-repo integration
