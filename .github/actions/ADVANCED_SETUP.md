# Advanced Setup Instructions

## Custom Deployment Scenarios

### 1. Multi-Region Deployment

#### Prerequisites
- Multiple AWS regions configured
- Regional DNS entries
- Cross-region VPC peering

#### Steps
1. Create regional environments:
   ```bash
   # For each region
   ./setup.ps1 -RepoName spectra-infra -OrgName Vesryin -AWSRegion $region
   ```

2. Configure regional secrets:
   ```bash
   # For each region
   gh secret set AWS_REGION_${region} -b $region
   gh secret set DB_HOST_${region} -b $db_host
   ```

3. Update workflow files to support regions

### 2. Air-Gapped Environment

#### Prerequisites
- Private Docker registry
- Internal npm registry
- VPN or direct connect

#### Steps
1. Configure private registries:
   ```bash
   gh variable set DOCKER_REGISTRY -b "private-registry.spectra.ai"
   gh variable set NPM_REGISTRY -b "npm.spectra.ai"
   ```

2. Set up network access:
   ```bash
   gh secret set VPN_CONFIG -b $vpn_config
   ```

3. Update workflow files for private networks

### 3. Compliance-Heavy Setup

#### Prerequisites
- Compliance requirements documented
- Audit logging enabled
- Security scanning tools

#### Steps
1. Enable extended auditing:
   ```bash
   gh api -X PUT /repos/:owner/:repo/actions/permissions \
     -f advanced_security_enabled=true
   ```

2. Configure security scanning:
   ```bash
   gh api -X PUT /repos/:owner/:repo/security-and-analysis \
     -f secret_scanning_enabled=true
   ```

3. Set up audit logs:
   ```bash
   gh api -X PUT /repos/:owner/:repo/actions/permissions \
     -f audit_log_retention_days=90
   ```

## Special Cases

### 1. Database Migration Workflows

#### First-Time Setup
1. Create migration environment:
   ```bash
   gh workflow enable database-migrations
   ```

2. Configure database access:
   ```bash
   gh secret set -e migration DB_ADMIN_USER -b $admin_user
   gh secret set -e migration DB_ADMIN_PASSWORD -b $admin_pass
   ```

3. Set up schema versioning:
   ```bash
   flyway baseline -baselineVersion=0
   ```

### 2. Secrets Rotation

#### Automated Rotation
1. Configure rotation schedule:
   ```yaml
   name: Rotate Secrets
   on:
     schedule:
       - cron: '0 0 1 * *'  # Monthly
   ```

2. Set up notifications:
   ```bash
   gh secret set SLACK_WEBHOOK -b $webhook_url
   ```

3. Enable audit logging:
   ```bash
   gh api -X PUT /repos/:owner/:repo/actions/permissions \
     -f audit_log_retention_days=90
   ```

### 3. Zero-Downtime Deployments

#### Configuration
1. Set up health checks:
   ```yaml
   healthCheck:
     path: /health
     initialDelay: 30
     period: 10
   ```

2. Configure rolling updates:
   ```yaml
   strategy:
     rollingUpdate:
       maxUnavailable: 25%
       maxSurge: 25%
   ```

3. Enable readiness probes:
   ```yaml
   readinessProbe:
     httpGet:
       path: /ready
       port: 8080
   ```

## Integration Points

### 1. External Service Integration

#### Setting Up Service Connections
1. Add service credentials:
   ```bash
   gh secret set SERVICE_API_KEY -b $api_key
   gh secret set SERVICE_ENDPOINT -b $endpoint
   ```

2. Configure service discovery:
   ```yaml
   service:
     discovery:
       enabled: true
       method: dns
   ```

3. Set up health monitoring:
   ```yaml
   monitoring:
     endpoints:
       - name: external-service
         url: ${SERVICE_ENDPOINT}/health
   ```

### 2. Monitoring Integration

#### Configuring Observability
1. Set up metrics collection:
   ```bash
   gh secret set PROMETHEUS_TOKEN -b $token
   ```

2. Configure log shipping:
   ```yaml
   logging:
     driver: fluentd
     options:
       fluentd-address: ${FLUENTD_HOST}:24224
   ```

3. Enable tracing:
   ```yaml
   tracing:
     enabled: true
     provider: jaeger
   ```

## Verification Procedures

### 1. Security Verification

#### Security Checks
1. Run security scan:
   ```bash
   gh workflow run security-scan
   ```

2. Verify secrets:
   ```bash
   gh secret list --json name,updated_at
   ```

3. Check permissions:
   ```bash
   gh api repos/:owner/:repo/actions/permissions
   ```

### 2. Performance Verification

#### Performance Tests
1. Run load tests:
   ```bash
   gh workflow run load-test
   ```

2. Check metrics:
   ```bash
   gh api repos/:owner/:repo/actions/runs/:run_id/timing
   ```

3. Verify scaling:
   ```bash
   kubectl get hpa -n ${NAMESPACE}
   ```

### 3. Compliance Verification

#### Compliance Checks
1. Run compliance scan:
   ```bash
   gh workflow run compliance-check
   ```

2. Generate audit report:
   ```bash
   gh api repos/:owner/:repo/actions/runs \
     --jq '.workflow_runs[] | select(.name=="Compliance")'
   ```

3. Verify configurations:
   ```bash
   gh api repos/:owner/:repo/actions/artifacts
   ```
