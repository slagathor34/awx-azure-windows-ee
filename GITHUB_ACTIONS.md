# GitHub Actions Integration Guide

## Overview

Your `sstormes/awx-azure-ee:latest` Docker image is fully compatible with GitHub Actions workflows. This guide shows you how to use it effectively for Azure and Windows automation.

## ✅ Why It Works in GitHub Actions

Your execution environment works in GitHub Actions because:

1. **Container Support**: GitHub Actions can run jobs in custom Docker containers
2. **ansible-runner Included**: The image contains `ansible-runner` required for automation
3. **All Dependencies**: Azure CLI, Python packages, and collections are pre-installed
4. **Cross-platform**: Built for `linux/amd64` which runs on GitHub's Ubuntu runners

## 🔧 Required GitHub Secrets

Set these secrets in your repository settings (Settings → Secrets and variables → Actions):

### Azure Authentication:
```
AZURE_CLIENT_ID=your-service-principal-id
AZURE_CLIENT_SECRET=your-service-principal-secret  
AZURE_TENANT_ID=your-tenant-id
AZURE_SUBSCRIPTION_ID=your-subscription-id
```

### Docker Hub (for CI/CD):
```
DOCKERHUB_USERNAME=sstormes
DOCKERHUB_TOKEN=your-docker-hub-token
```

### Windows Authentication (if using Windows hosts):
```
WINDOWS_USERNAME=domain\username
WINDOWS_PASSWORD=your-password
```

## 🚀 Usage Patterns

### 1. Direct Container Usage
```yaml
jobs:
  ansible-job:
    runs-on: ubuntu-latest
    container:
      image: sstormes/awx-azure-ee:latest
      options: --user root
```

### 2. With ansible-runner (AWX-like)
```yaml
steps:
  - name: Run with ansible-runner
    run: |
      ansible-runner run /runner \
        --playbook azure-deployment.yml \
        --inventory inventories/dev/
```

### 3. Matrix Strategy for Multiple Environments
```yaml
strategy:
  matrix:
    environment: [dev, staging, prod]
    
container:
  image: sstormes/awx-azure-ee:latest
```

## 📦 Workflow Files Included

- `.github/workflows/ansible-azure-windows.yml` - Main automation workflow
- `inventories/dev/hosts.yml` - Sample inventory
- `playbooks/azure-deployment.yml` - Azure infrastructure deployment
- `playbooks/windows-config.yml` - Windows server configuration

## 🔄 CI/CD Pipeline Features

The included workflow provides:

1. **Automated Testing**: Verifies the execution environment works
2. **Multi-environment Support**: Dev, staging, production deployments  
3. **Azure Integration**: Service principal authentication
4. **Windows Support**: WinRM/CredSSP connectivity testing
5. **Docker Registry**: Automatic image builds and pushes

## ⚡ Performance Optimizations

### Image Size Optimization
Your current image (~3GB) can be optimized by:
```dockerfile
# Use multi-stage builds
FROM sstormes/awx-azure-ee:latest as base

# Production stage with minimal layers
FROM quay.io/centos/centos:stream9 as production
COPY --from=base /usr/local /usr/local
```

### GitHub Actions Caching
```yaml
- name: Cache Docker layers
  uses: actions/cache@v3
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
```

## 🔍 Troubleshooting

### Common Issues:

1. **Permission Errors**:
   ```yaml
   container:
     options: --user root  # Run as root in container
   ```

2. **Azure Authentication**:
   ```yaml
   - name: Azure Login
     run: |
       az login --service-principal \
         --username $AZURE_CLIENT_ID \
         --password $AZURE_CLIENT_SECRET \
         --tenant $AZURE_TENANT_ID
   ```

3. **Windows Connectivity**:
   ```yaml
   env:
     ANSIBLE_HOST_KEY_CHECKING: false
     ANSIBLE_WINRM_SERVER_CERT_VALIDATION: ignore
   ```

### Debugging Steps:
```yaml
- name: Debug environment
  run: |
    ansible --version
    ansible-runner --version
    az --version
    python3 -c "import azure; print('Azure SDK available')"
    python3 -c "import winrm; print('WinRM available')"
```

## 📈 Advanced Usage

### Self-hosted Runners
```yaml
runs-on: self-hosted  # Use your own runners
container:
  image: sstormes/awx-azure-ee:latest
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock  # Docker-in-Docker
```

### Artifact Collection
```yaml
- name: Collect Ansible logs
  uses: actions/upload-artifact@v3
  if: always()
  with:
    name: ansible-logs
    path: |
      /runner/artifacts/
      /tmp/ansible.log
```

### Parallel Execution
```yaml
strategy:
  matrix:
    region: [eastus, westus, westeurope]
    environment: [dev, staging]
  fail-fast: false
```

## 🔐 Security Best Practices

1. **Use GitHub Environments** for production deployments
2. **Rotate secrets regularly** 
3. **Use least privilege** service principals
4. **Enable branch protection** for main branch
5. **Review workflow permissions** regularly

## 🎯 Next Steps

1. **Test the workflow**: Push to your repository to trigger the workflow
2. **Customize playbooks**: Modify the sample playbooks for your needs
3. **Add environments**: Create staging/prod inventory files
4. **Monitor runs**: Check the Actions tab for execution logs
5. **Optimize image**: Consider smaller base images for faster runs

Your execution environment is now ready for production use in GitHub Actions! 🚀
