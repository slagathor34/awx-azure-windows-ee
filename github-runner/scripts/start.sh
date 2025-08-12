#!/bin/bash

# Start Docker daemon
echo "Starting Docker daemon..."
sudo dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2376 &

# Wait for Docker to start
sleep 10

# Check if Docker is running
docker --version
echo "Docker daemon started successfully"

# Configure and start GitHub runner
/home/runner/scripts/configure-runner.sh
