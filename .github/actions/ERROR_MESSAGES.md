# GitHub Actions Error Messages Explained

## Common Error Messages

### "Context access might be invalid"
This warning appears when using variables or secrets in workflows. It's not an error, just a warning that GitHub can't validate the existence of the secret/variable at analysis time.

### Required Secrets
All required secrets are documented in `.github/environments/secret-usage.md`. Ensure they are configured in:
1. Repository settings for repo-level secrets
2. Environment settings for environment-specific secrets

### Variable Context
- `secrets.*` - Repository and environment secrets
- `github.*` - GitHub context (event, repo info, etc.)
- `env.*` - Environment variables set in workflow
- `vars.*` - Repository and environment variables

## Environment-Specific Configuration

Each environment (development, staging, production) has its own:
- Protection rules
- Required secrets
- Deployment conditions
- Required approvers (production only)

## Workflow Dependencies

The shared configuration in `_shared.yml` provides reusable jobs that other workflows can reference using the `uses` keyword.

## Error Resolution

1. Missing secrets warnings: Add secrets in GitHub settings
2. Invalid variable context: Use correct context prefix
3. Unknown job dependencies: Define jobs before referencing
4. Missing 'on' trigger: Add event triggers for workflows

See `.github/environments/README.md` for complete setup instructions.
