# Advanced Setup Guide

## Table of Contents
- [Multi-Region Deployment](#multi-region-deployment)
- [High Availability Configuration](#high-availability-configuration)
- [Air-Gapped Installation](#air-gapped-installation)
- [Compliance Mode Setup](#compliance-mode-setup)
- [Custom Security Controls](#custom-security-controls)
- [Advanced Monitoring](#advanced-monitoring)

## Multi-Region Deployment

### Prerequisites
- AWS access in all target regions
- Domain and SSL certificates for each region
- Regional database strategy defined

### Configuration Steps

1. Create Regional Infrastructure
```powershell
# For each region
$regions = @('us-west-2', 'eu-west-1', 'ap-southeast-1')
foreach ($region in $regions) {
    Initialize-SpectraEnvironment -Environment production `
                                -AWSRegion $region `
                                -ConfigPath .github/environments/regional
}
```

2. Configure Global Load Balancing
```yaml
# Route 53 Configuration
route53:
  policy: latency
  health_checks:
    path: /health
    interval: 30
    failure_threshold: 3
```

3. Set Up Cross-Region Replication
```yaml
# Database Replication
database:
  primary_region: us-west-2
  replica_regions:
    - eu-west-1
    - ap-southeast-1
  sync_mode: async
```

## High Availability Configuration

### Database HA Setup
```yaml
database:
  multi_az: true
  read_replicas: 2
  backup_strategy:
    type: continuous
    retention: 35d
    cross_region: true
```

### Application HA Setup
```yaml
kubernetes:
  topology_spread_constraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
  pod_disruption_budget:
    minAvailable: "75%"
```

## Air-Gapped Installation

### Prerequisites
- Local artifact registry
- Offline package repository
- Security compliance documentation

### Setup Steps

1. Pre-download Dependencies
```powershell
# Create offline package bundle
New-OfflinePackageBundle -OutputPath ./offline-bundle `
                        -Include @(
                            'docker-images',
                            'helm-charts',
                            'npm-packages',
                            'python-packages'
                        )
```

2. Configure Private Registries
```yaml
docker:
  registry:
    url: registry.internal
    credentials: 
      secretName: registry-auth

helm:
  repositories:
    - name: private
      url: https://charts.internal
```

3. Network Security
```yaml
network:
  egress:
    allowed: []  # No outbound internet access
  ingress:
    loadBalancer:
      internal: true
```

## Compliance Mode Setup

### HIPAA Compliance
```yaml
security:
  encryption:
    at_rest: true
    in_transit: true
  audit:
    enabled: true
    retention: 6y
  access_control:
    rbac:
      strict: true
    ip_whitelist:
      enabled: true
```

### SOC2 Configuration
```yaml
monitoring:
  audit_logs:
    enabled: true
    destinations:
      - cloudwatch
      - s3
  alerts:
    security_events: true
    compliance_violations: true
```

## Custom Security Controls

### Network Policies
```yaml
network_policies:
  default:
    ingress:
      - from:
          - podSelector:
              matchLabels:
                app.kubernetes.io/part-of: spectra
    egress:
      - to:
          - namespaceSelector:
              matchLabels:
                environment: production
```

### Pod Security Policies
```yaml
pod_security_policies:
  privileged: false
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsUser:
    rule: MustRunAsNonRoot
```

## Advanced Monitoring

### Prometheus Federation
```yaml
prometheus:
  federation:
    enabled: true
    scrape_interval: 15s
    targets:
      - job_name: federate
        static_configs:
          - targets:
            - prometheus-us-west.internal:9090
            - prometheus-eu-west.internal:9090
```

### Custom Dashboards
```yaml
grafana:
  dashboards:
    deployment:
      file: dashboards/deployment-health.json
    security:
      file: dashboards/security-metrics.json
    compliance:
      file: dashboards/compliance-status.json
```

### Alert Manager Configuration
```yaml
alertmanager:
  receivers:
    - name: 'team-sre'
      slack_configs:
        - channel: '#sre-alerts'
          send_resolved: true
    - name: 'team-security'
      pagerduty_configs:
        - service_key: 'YOUR_KEY'
  route:
    receiver: 'team-sre'
    group_by: ['alertname', 'cluster', 'service']
    group_wait: 30s
    group_interval: 5m
    repeat_interval: 4h
    routes:
      - match:
          severity: security
        receiver: 'team-security'
```

### Logging Pipeline
```yaml
fluentd:
  custom_parsers:
    - name: app_logs
      format: json
      time_key: timestamp
  filters:
    - name: kubernetes_metadata
      type: kubernetes_metadata
    - name: record_transformer
      type: record_transformer
      enable_ruby: true
      records:
        - environment: ${record["kubernetes"]["namespace_name"]}
  outputs:
    - name: elasticsearch
      type: elasticsearch
      host: elasticsearch.monitoring
      port: 9200
      index_name: logs-%Y.%m.%d
      buffer:
        type: file
        path: /var/log/fluentd-buffers/kubernetes.system.buffer
        flush_mode: interval
        retry_type: exponential_backoff
```
