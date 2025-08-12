#!/bin/bash

# GitHub Runner Configuration Script
set -e

echo "Configuring GitHub Actions Runner..."

# Check if required environment variables are set
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Error: GITHUB_TOKEN environment variable is required"
    exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
    echo "Error: GITHUB_REPOSITORY environment variable is required (format: owner/repo)"
    exit 1
fi

RUNNER_NAME=${RUNNER_NAME:-"docker-runner-$(hostname)"}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,docker,linux,x64"}

echo "Repository: $GITHUB_REPOSITORY"
echo "Runner Name: $RUNNER_NAME"
echo "Runner Labels: $RUNNER_LABELS"

# Get registration token from GitHub API
echo "Getting registration token from GitHub..."
REGISTRATION_TOKEN=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token" | jq -r .token)

if [[ "$REGISTRATION_TOKEN" == "null" || -z "$REGISTRATION_TOKEN" ]]; then
    echo "Error: Failed to get registration token. Check your GitHub token permissions."
    exit 1
fi

echo "Registration token obtained successfully"

# Configure the runner
echo "Configuring runner..."
cd /home/runner
./config.sh \
    --url "https://github.com/$GITHUB_REPOSITORY" \
    --token "$REGISTRATION_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "_work" \
    --unattended \
    --replace

echo "Runner configured successfully!"

# Ensure proper permissions on runner directories
mkdir -p /home/runner/_work/_tool
chmod -R 755 /home/runner/_work
chmod -R 755 /home/runner/.cache

echo "Starting runner..."

# Start the runner
exec ./run.sh
