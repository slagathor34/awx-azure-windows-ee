#!/bin/bash

# Cleanup script for GitHub Runner
set -e

echo "Cleaning up GitHub Actions Runner..."

if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Warning: GITHUB_TOKEN not set, skipping cleanup"
    exit 0
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
    echo "Warning: GITHUB_REPOSITORY not set, skipping cleanup"
    exit 0
fi

cd /home/runner

# Check if runner is configured
if [[ ! -f ".runner" ]]; then
    echo "Runner not configured, skipping cleanup"
    exit 0
fi

echo "Getting removal token from GitHub..."
REMOVAL_TOKEN=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/remove-token" | jq -r .token)

if [[ "$REMOVAL_TOKEN" != "null" && -n "$REMOVAL_TOKEN" ]]; then
    echo "Removing runner from GitHub..."
    ./config.sh remove --token "$REMOVAL_TOKEN"
    echo "Runner removed successfully"
else
    echo "Warning: Could not get removal token, runner may need manual cleanup"
fi
