# Setting up Multi-Repository Integration

This guide explains how to set up the integration between all Spectra repositories.

## Prerequisites

1. Access to all repositories:
   - spectra-infra (this repository)
   - spectra-core
   - spectra-web
   - spectra-api

2. Required access tokens and credentials:
   - GitHub Personal Access Token with repo scope
   - AWS credentials
   - Docker Hub credentials
   - Vercel tokens
   - Railway tokens
   - Database credentials

## Initial Setup

1. **Fork and Clone All Repositories**:
   ```bash
   git clone https://github.com/Vesryin/spectra-infra.git
   git clone https://github.com/Vesryin/spectra-core.git
   git clone https://github.com/Vesryin/spectra-web.git
   git clone https://github.com/Vesryin/spectra-api.git
   ```

2. **Set Up GitHub Secrets**:
   
   In each repository, set up the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`
   - `REPO_ACCESS_TOKEN` (GitHub PAT)
   - `VERCEL_TOKEN` (for web app)
   - `RAILWAY_TOKEN` (if using Railway)
   - `DB_HOST`
   - `DB_USER`
   - `DB_PASSWORD`

3. **Copy CI/CD Templates**:
   
   From spectra-infra, copy the appropriate template to each repository:
   - spectra-core: `ci/templates/core-pipeline.yml` → `.github/workflows/ci.yml`
   - spectra-web: `ci/templates/web-pipeline.yml` → `.github/workflows/ci.yml`
   - spectra-api: `ci/templates/api-pipeline.yml` → `.github/workflows/ci.yml`

## Setting Up Environments

1. **Initialize Infrastructure**:
   ```bash
   # In spectra-infra repository
   gh workflow run setup-environment.yml -f environment=development
   ```

2. **Verify Setup**:
   ```bash
   kubectl get pods -n spectra-development
   kubectl get services -n spectra-development
   kubectl get ingress -n spectra-development
   ```

## Repository Communication Flow

1. **Core Updates**:
   - Changes in spectra-core trigger core-pipeline.yml
   - On successful publish, notifies spectra-api and spectra-web

2. **API Updates**:
   - Changes in spectra-api trigger api-pipeline.yml
   - Builds Docker image and notifies spectra-infra
   - spectra-infra updates Kubernetes deployments
   - Notifies spectra-web of API changes

3. **Web Updates**:
   - Changes in spectra-web trigger web-pipeline.yml
   - Automatically updates when core or API changes

4. **Infrastructure Updates**:
   - Changes in spectra-infra trigger infrastructure updates
   - Manages all deployment environments
   - Coordinates cross-repository deployments

## Troubleshooting

1. **Check Repository Dispatch Events**:
   ```bash
   gh api repos/Vesryin/spectra-infra/dispatches/events
   ```

2. **Verify Webhooks**:
   - Check repository settings → Webhooks
   - Verify recent deliveries
   - Check for failed webhook deliveries

3. **Check Deployment Status**:
   ```bash
   kubectl get pods -A | grep spectra
   kubectl get events -n spectra-development
   ```

4. **Check Pipeline Logs**:
   - Visit GitHub Actions tab in each repository
   - Review workflow run logs
   - Check for failed steps or missing secrets

## Common Issues

1. **Missing Secrets**:
   - Ensure all required secrets are set in each repository
   - Check secret names match the CI/CD templates

2. **Failed Deployments**:
   - Check Kubernetes events: `kubectl get events`
   - Verify pod logs: `kubectl logs -f <pod-name>`
   - Check container health probes

3. **Cross-Repository Communication**:
   - Verify GitHub token permissions
   - Check repository dispatch event logs
   - Ensure webhook URLs are correct

## Monitoring Integration

Monitor the integrated system using:

1. **Prometheus/Grafana**:
   ```bash
   kubectl port-forward svc/grafana 3000:3000 -n monitoring
   ```
   Visit http://localhost:3000

2. **Logging**:
   ```bash
   kubectl port-forward svc/kibana 5601:5601 -n logging
   ```
   Visit http://localhost:5601

## Testing Integration

Run integration tests across repositories:

1. **Local Testing**:
   ```bash
   docker-compose -f docker/docker-compose.yml up
   ```

2. **Staging Environment**:
   ```bash
   gh workflow run setup-environment.yml -f environment=staging
   ```

3. **End-to-End Tests**:
   ```bash
   npm run test:e2e
   ```
