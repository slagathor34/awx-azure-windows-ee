#!/bin/bash

# GitHub Runner Entrypoint Script
# This script ensures proper permissions and starts the runner

set -e

echo "Setting up GitHub runner permissions..."

# Ensure runner directories exist with proper ownership
mkdir -p /home/runner/_work
mkdir -p /home/runner/.runner  
mkdir -p /home/runner/.cache
mkdir -p /home/runner/_work/_tool

# Fix ownership and permissions
chown -R runner:runner /home/runner
chmod -R 755 /home/runner/_work
chmod -R 755 /home/runner/.runner
chmod -R 755 /home/runner/.cache

echo "Starting supervisord..."

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
