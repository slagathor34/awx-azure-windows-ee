#!/bin/bash

# GitHub Self-Hosted Runner Setup Script
set -e

echo "=== GitHub Self-Hosted Runner Setup ==="
echo ""

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if .env file exists
if [[ ! -f .env ]]; then
    echo "Creating .env file from template..."
    cp .env.template .env
    echo ""
    echo "⚠️  Please edit the .env file and add your GitHub token and repository:"
    echo "   - GITHUB_TOKEN: Personal Access Token with 'repo' and 'workflow' permissions"
    echo "   - GITHUB_REPOSITORY: Your repository in format owner/repo"
    echo ""
    echo "To create a GitHub Personal Access Token:"
    echo "1. Go to GitHub Settings > Developer settings > Personal access tokens"
    echo "2. Click 'Generate new token (classic)'"
    echo "3. Select scopes: 'repo' and 'workflow'"
    echo "4. Copy the token to your .env file"
    echo ""
    echo "After editing .env, run this script again."
    exit 1
fi

# Source environment variables
source .env

# Validate required variables
if [[ -z "$GITHUB_TOKEN" || "$GITHUB_TOKEN" == "your_github_token_here" ]]; then
    echo "Error: Please set GITHUB_TOKEN in the .env file"
    exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
    echo "Error: Please set GITHUB_REPOSITORY in the .env file"
    exit 1
fi

echo "Configuration:"
echo "  Repository: $GITHUB_REPOSITORY"
echo "  Runner Name: ${RUNNER_NAME:-docker-runner-rhel-windows}"
echo "  Runner Labels: ${RUNNER_LABELS:-self-hosted,docker,linux,x64,rhel-windows-ee}"
echo ""

# Build and start the runner
echo "Building GitHub Runner Docker image..."
docker-compose build

echo ""
echo "Starting GitHub Runner..."
docker-compose up -d

echo ""
echo "✅ GitHub Runner is starting up!"
echo ""
echo "To check the logs:"
echo "  docker-compose logs -f"
echo ""
echo "To stop the runner:"
echo "  docker-compose down"
echo ""
echo "The runner should appear in your repository settings under:"
echo "Settings > Actions > Runners"
echo ""
echo "Runner URL: https://github.com/$GITHUB_REPOSITORY/settings/actions/runners"
