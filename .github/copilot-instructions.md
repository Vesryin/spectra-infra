---
applyTo: '**'
---
# Spectra-Infra AI Coding Agent Instructions

## Project Overview

Spectra-Infra manages infrastructure, deployment configurations, and automation for Spectra AI. This repository serves as the backbone for CI/CD pipelines, containerization, cloud deployments, and infrastructure-as-code.

## Repository Structure

```
spectra-infra/
├── docker/          # Dockerfiles and container configurations
├── ci/              # CI/CD pipeline configurations 
├── scripts/         # Deployment and automation scripts
├── secrets/         # Environment variable templates and security documentation
├── kubernetes/      # Kubernetes manifests for container orchestration
├── terraform/       # Infrastructure as Code using Terraform
├── monitoring/      # Monitoring and observability configurations
├── logging/         # Centralized logging configurations
├── migrations/      # Database schema migrations
└── .github/         # GitHub configurations and workflows
```

## Key Technologies & Tools

- **Containerization**: Docker
- **Cloud Deployment**: Railway, Vercel
- **Container Orchestration**: Kubernetes
- **Infrastructure as Code**: Terraform
- **Database Migrations**: Flyway
- **Monitoring**: Prometheus, Grafana
- **Logging**: Fluentd, Elasticsearch
- **Version Control**: Git
- **CI/CD**: GitHub Actions

## Development Workflow

1. Always begin with the Strategist AI's deployment and infrastructure roadmap
2. Follow security best practices for managing secrets and environment variables
3. Ensure all infrastructure changes are validated through linters and testing tools
4. Document changes thoroughly for auditability and reproducibility

## Coding Standards

- Write clear, well-documented scripts for deployments and infrastructure automation
- Follow the principle of minimal configuration for Dockerfiles, Kubernetes manifests, and CI/CD YAMLs
- Implement security best practices across all infrastructure components
- Use descriptive commit messages that explain the purpose of infrastructure changes

## Important Commands

```bash
# Setup and installation
git clone <your-github-url>/spectra-infra.git
cd spectra-infra

# Local development
./scripts/setup-dev.ps1               # Set up development environment (Windows PowerShell)
docker-compose -f docker/docker-compose.yml up -d  # Start local services

# Docker commands
docker build -t spectra-service -f docker/service/Dockerfile .
docker run -p 8080:8080 spectra-service

# Deployment commands
./scripts/deploy.sh development        # Deploy to local development
./scripts/deploy.sh staging            # Deploy to staging environment
./scripts/deploy.sh production         # Deploy to production environment

# Kubernetes commands
kubectl apply -f kubernetes/           # Apply all Kubernetes manifests
kubectl get pods -n spectra            # Check running pods in spectra namespace
kubectl logs -f deployment/spectra-api -n spectra  # Stream logs from API service

# Database migration
cd migrations
docker build -t spectra-migrations .
docker run --rm -e FLYWAY_URL=jdbc:postgresql://localhost:5432/spectra \
  -e FLYWAY_USER=postgres -e FLYWAY_PASSWORD=postgres \
  spectra-migrations migrate

# Terraform commands
cd terraform
terraform init                         # Initialize Terraform
terraform plan                         # Preview infrastructure changes
terraform apply                        # Apply infrastructure changes
terraform destroy                      # Tear down infrastructure
```

## Integration Points

- Docker Hub for container registry
- Railway/Vercel for cloud deployments
- AWS EKS for Kubernetes orchestration
- AWS RDS for managed PostgreSQL database
- Prometheus/Grafana for monitoring and observability
- ELK Stack (Elasticsearch, Fluentd) for centralized logging
- GitHub Actions for CI/CD workflows
- Terraform Cloud for infrastructure state management

## Cross-Component Communication

- Services should communicate through well-defined APIs
- Use environment variables for configuration between components
- Implement proper logging for traceability across infrastructure components

## Security Guidelines

- Never commit secrets or credentials to the repository
- Use environment variables for sensitive information
- Follow the principle of least privilege for all service accounts
- Regularly rotate keys and credentials

## References

- See `README.md` for high-level project overview
- Consult `.github/instructions/spectra-infra.instructions.md` for detailed setup instructions
