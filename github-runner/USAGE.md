# Using the GitHub Self-Hosted Runner

## Overview

The self-hosted GitHub runner allows you to run your Red Hat & Windows automation workflows on your own infrastructure, giving you:

- **Full control** over the execution environment
- **Access to local resources** like internal networks
- **Custom software** and configurations
- **Better performance** for your specific use cases
- **No GitHub Actions minutes usage** for private repositories

## Setup Instructions

### 1. GitHub Token Setup

Create a GitHub Personal Access Token:

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
4. Copy the token

### 2. Configure Environment

```bash
cd github-runner
cp .env.template .env
```

Edit `.env` file:
```bash
GITHUB_TOKEN=ghp_your_token_here
GITHUB_REPOSITORY=slagathor34/awx-azure-windows-ee
RUNNER_NAME=docker-runner-rhel-windows
RUNNER_LABELS=self-hosted,docker,linux,x64,rhel-windows-ee
```

### 3. Start the Runner

```bash
./setup.sh
```

Or manually:
```bash
docker-compose up -d
```

### 4. Verify Runner Registration

1. Go to your GitHub repository
2. Navigate to Settings → Actions → Runners
3. You should see your runner listed as "Online"

## Workflow Updates

The GitHub Actions workflow has been updated to use the self-hosted runner:

```yaml
jobs:
  redhat-automation:
    runs-on: [self-hosted, rhel-windows-ee]  # Changed from ubuntu-latest
    
  windows-automation:
    runs-on: [self-hosted, rhel-windows-ee]  # Changed from ubuntu-latest
    
  ansible-runner-job:
    runs-on: [self-hosted, rhel-windows-ee]  # Changed from ubuntu-latest
```

## How It Works

### Runner Architecture

```
┌─────────────────────────┐
│   GitHub Repository     │
│   ┌─────────────────┐   │
│   │    Workflow     │   │
│   │    triggers     │   │
│   └─────────────────┘   │
└─────────────────────────┘
           │
           ▼
┌─────────────────────────┐
│   Self-Hosted Runner    │
│   ┌─────────────────┐   │
│   │  Docker Engine  │   │
│   │  ┌───────────┐  │   │
│   │  │    EE     │  │   │  ← Your execution environment
│   │  │ Container │  │   │
│   │  └───────────┘  │   │
│   └─────────────────┘   │
└─────────────────────────┘
```

### Execution Flow

1. **Workflow Trigger**: GitHub Actions workflow is triggered
2. **Runner Assignment**: GitHub assigns job to your self-hosted runner
3. **Container Execution**: Runner pulls and runs your execution environment container
4. **Playbook Execution**: Ansible playbooks run inside the container
5. **Results**: Results are reported back to GitHub

### Container Usage

The workflow now runs commands inside your execution environment container:

```bash
# Instead of running directly on runner:
ansible-playbook playbooks/redhat-config.yml

# Commands now run in container:
docker run --rm -v ${{ github.workspace }}:/workspace -w /workspace \
  -e ANSIBLE_HOST_KEY_CHECKING=false \
  sstormes/awx-azure-ee:latest \
  ansible-playbook playbooks/redhat-config.yml
```

## Management Commands

### Check Status
```bash
# View all containers
docker-compose ps

# View runner logs
docker-compose logs -f github-runner

# Check GitHub registration
docker-compose exec github-runner cat /home/runner/.runner
```

### Restart Runner
```bash
# Restart the runner
docker-compose restart

# Full restart (re-register)
docker-compose down && docker-compose up -d
```

### Stop Runner
```bash
# Stop runner (keeps registration)
docker-compose stop

# Remove runner (unregisters from GitHub)
docker-compose down
```

## Advanced Configuration

### Custom Runner Configuration

Edit `docker-compose.yml` to customize:

```yaml
environment:
  - RUNNER_NAME=my-custom-runner
  - RUNNER_LABELS=self-hosted,docker,linux,custom-tag
  - RUNNER_WORK_DIRECTORY=/custom/work/path
```

### Multiple Runners

Scale to multiple runners:
```bash
docker-compose up -d --scale github-runner=3
```

### Persistent Storage

The runner uses Docker volumes for persistence:
- `runner-work`: Job workspace data
- `runner-cache`: Runner cache and tools

### Network Configuration

The runner creates its own network:
```yaml
networks:
  github-runner-network:
    driver: bridge
```

## Security Considerations

### Runner Security

1. **Privileged Mode**: Runner runs in privileged mode for Docker access
2. **Token Security**: Store GitHub tokens securely, rotate regularly
3. **Network Access**: Runner can access your internal networks
4. **Resource Limits**: Consider setting CPU/memory limits

### Recommended Security Practices

```yaml
# Add resource limits to docker-compose.yml
services:
  github-runner:
    mem_limit: 4g
    cpus: 2.0
    security_opt:
      - no-new-privileges:true
```

### Firewall Configuration

Ensure the runner can reach:
- `github.com` (port 443)
- `api.github.com` (port 443)
- Docker Hub (if pulling images)

## Troubleshooting

### Common Issues

1. **Runner Not Appearing**
   ```bash
   # Check logs for registration errors
   docker-compose logs github-runner
   
   # Verify GitHub token permissions
   curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
   ```

2. **Docker Permission Errors**
   ```bash
   # Ensure Docker daemon is accessible
   docker info
   
   # Check if user is in docker group
   groups $USER
   ```

3. **Network Connectivity**
   ```bash
   # Test GitHub connectivity
   curl -I https://api.github.com
   
   # Check DNS resolution
   nslookup github.com
   ```

4. **Container Build Failures**
   ```bash
   # Rebuild with verbose output
   docker-compose build --no-cache --progress=plain
   ```

### Reset Everything

Complete reset if things go wrong:
```bash
# Stop everything
docker-compose down -v

# Remove all related containers and images
docker system prune -a

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d
```

## Monitoring

### Health Checks

```bash
# Check if runner is healthy
curl -s "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners" \
  -H "Authorization: token $GITHUB_TOKEN" | jq '.runners[] | select(.name | contains("docker-runner"))'
```

### Resource Usage

```bash
# Monitor resource usage
docker stats $(docker-compose ps -q)

# Check disk usage
docker system df
```

### Logs

```bash
# Real-time logs
docker-compose logs -f

# Specific service logs
docker-compose logs github-runner

# System logs
docker-compose exec github-runner tail -f /var/log/supervisor/github-runner.out.log
```

## Benefits of Self-Hosted Runner

1. **Cost Savings**: No GitHub Actions minutes usage
2. **Performance**: Faster execution on your hardware
3. **Network Access**: Can reach internal resources
4. **Custom Environment**: Install any software you need
5. **Data Security**: Jobs run on your infrastructure
6. **Debugging**: Full access to logs and debugging tools
