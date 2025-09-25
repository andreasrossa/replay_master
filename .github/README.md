# GitHub Actions CI/CD Pipeline

This repository includes a comprehensive CI/CD pipeline that runs tests, builds Docker images, performs security scans, and handles deployment.

## Workflow Overview

The pipeline consists of four main jobs:

### 1. Test Job
- **Triggers**: On every push and pull request
- **Environment**: Ubuntu latest with PostgreSQL service
- **Actions**:
  - Sets up Elixir/OTP environment
  - Caches dependencies and build artifacts
  - Runs the full test suite with database integration
  - Uses PostgreSQL 15 as the test database

### 2. Build Job
- **Triggers**: Only on pushes to `main` or `develop` branches
- **Dependencies**: Requires test job to pass
- **Actions**:
  - Builds multi-platform Docker image (AMD64/ARM64)
  - Pushes to GitHub Container Registry (ghcr.io)
  - Uses Docker Buildx for advanced build features
  - Implements layer caching for faster builds

### 3. Security Scan Job
- **Triggers**: Only on pushes to `main` or `develop` branches
- **Dependencies**: Requires build job to complete
- **Actions**:
  - Runs Trivy vulnerability scanner on the Docker image
  - Uploads security scan results to GitHub Security tab
  - Provides detailed security reports

### 4. Deploy Job
- **Triggers**: Only on pushes to `main` branch
- **Dependencies**: Requires build and security scan to pass
- **Environment**: Uses GitHub's production environment
- **Actions**:
  - Placeholder for production deployment
  - Can be customized for your deployment strategy

## Required GitHub Secrets

The workflow uses the following secrets (all are automatically provided by GitHub):

- `GITHUB_TOKEN`: Automatically provided by GitHub Actions
  - Used for pushing to GitHub Container Registry
  - No additional setup required

## Container Registry

Images are automatically pushed to GitHub Container Registry at:
```
ghcr.io/[your-username]/replay_master
```

### Image Tags
- `latest`: Latest build from main branch
- `main`: Latest build from main branch
- `develop`: Latest build from develop branch
- `[branch]-[commit-sha]`: Specific commit builds

## Customization

### Adding Custom Secrets
If you need additional secrets for deployment or other operations:

1. Go to your repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Add new repository secrets
4. Reference them in the workflow as `${{ secrets.YOUR_SECRET_NAME }}`

### Deployment Configuration
The deploy job currently contains placeholder commands. Customize it for your deployment strategy:

```yaml
- name: Deploy to production
  run: |
    # Example Kubernetes deployment
    kubectl set image deployment/replay-master app=${{ needs.build.outputs.image-tag }}
    
    # Example Helm deployment
    helm upgrade replay-master ./helm-chart --set image.tag=${{ needs.build.outputs.image-tag }}
    
    # Example Docker Compose deployment
    docker-compose pull
    docker-compose up -d
```

### Environment Variables
The workflow sets these environment variables:
- `MIX_ENV=test` for the test job
- `ELIXIR_VERSION=1.17.1` (matches your mix.exs)
- `OTP_VERSION=26.2.5` (matches your Dockerfile)

### Database Configuration
The test job uses PostgreSQL 15 with these settings:
- Database: `replay_master_test`
- User: `postgres`
- Password: `postgres`
- Port: `5432`

## Monitoring

### Workflow Status
- View workflow runs in the "Actions" tab of your repository
- Each job shows detailed logs and execution time
- Failed jobs will show specific error messages

### Security Reports
- Security scan results appear in the "Security" tab
- Vulnerabilities are categorized by severity
- Detailed remediation guidance is provided

### Container Registry
- View pushed images in the "Packages" section of your repository
- Images include metadata and vulnerability scan results
- Download and inspect images locally

## Troubleshooting

### Common Issues

1. **Test Failures**
   - Check database connection in test logs
   - Verify all dependencies are properly installed
   - Ensure test environment variables are correct

2. **Build Failures**
   - Check Dockerfile syntax and dependencies
   - Verify all required files are present
   - Check for platform-specific build issues

3. **Security Scan Failures**
   - Review vulnerability reports in Security tab
   - Update base images or dependencies as needed
   - Consider adding exceptions for false positives

4. **Deployment Failures**
   - Verify deployment commands and permissions
   - Check environment-specific configurations
   - Ensure target environment is accessible

### Performance Optimization

- **Caching**: The workflow uses aggressive caching for dependencies and build artifacts
- **Parallel Jobs**: Tests and builds run in parallel where possible
- **Multi-platform**: Only builds for platforms you actually need
- **Layer Caching**: Docker builds use GitHub Actions cache for faster subsequent builds

## Contributing

When contributing to this repository:

1. Create a feature branch from `develop`
2. Make your changes and push to your branch
3. Create a pull request to `main`
4. The CI pipeline will automatically run tests
5. Once merged to `main`, the full pipeline will run including build and deployment

For more information about GitHub Actions, see the [official documentation](https://docs.github.com/en/actions).
