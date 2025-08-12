# GitHub Self-Hosted Runner in Docker

This directory contains everything needed to run a GitHub self-hosted runner in Docker that can execute your Red Hat & Windows automation workflows.

## Quick Setup

1. **Copy the environment template:**
   ```bash
   cp .env.template .env
   ```

2. **Edit the `.env` file with your GitHub details:**
   ```bash
   # Required: GitHub Personal Access Token
   GITHUB_TOKEN=ghp_your_token_here
   
   # Required: Your repository
   GITHUB_REPOSITORY=slagathor34/awx-azure-windows-ee
   
   # Optional: Custom runner name
   RUNNER_NAME=docker-runner-rhel-windows
   
   # Optional: Custom labels
   RUNNER_LABELS=self-hosted,docker,linux,x64,rhel-windows-ee
   ```

3. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

## GitHub Token Setup

To create a GitHub Personal Access Token:

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select the following scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
4. Copy the token and add it to your `.env` file

## Manual Commands

If you prefer manual control:

```bash
# Build the runner image
docker-compose build

# Start the runner
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the runner
docker-compose down

# Restart the runner
docker-compose restart
```

## Features

- **Docker-in-Docker**: Can build and run Docker containers
- **Persistent Storage**: Runner work directory and cache are preserved
- **Auto-Registration**: Automatically registers with GitHub on startup
- **Auto-Cleanup**: Removes runner from GitHub on shutdown
- **Supervisor Management**: Uses supervisor to manage processes
- **Custom Labels**: Tagged with `rhel-windows-ee` for targeting specific workflows

## Troubleshooting

### Check Runner Status
```bash
# View container logs
docker-compose logs github-runner

# Check if runner is registered in GitHub
# Go to: https://github.com/your-repo/settings/actions/runners
```

### Common Issues

1. **Token Permissions**: Ensure your GitHub token has `repo` and `workflow` scopes
2. **Docker Access**: The runner needs access to Docker daemon (runs in privileged mode)
3. **Network Issues**: Check firewall settings if the runner can't reach GitHub

### Reset Runner

If you need to completely reset the runner:

```bash
docker-compose down -v  # Remove volumes too
docker-compose up -d
```

## Security Notes

- The runner runs in privileged mode to access Docker
- Store your GitHub token securely (use environment variables, not hard-coded)
- Consider running on a dedicated machine or VM for security
- Regularly rotate your GitHub tokens

## Scaling

To run multiple runners:

```bash
# Scale to 3 runners
docker-compose up -d --scale github-runner=3
```

Each runner will get a unique name and register separately with GitHub.
