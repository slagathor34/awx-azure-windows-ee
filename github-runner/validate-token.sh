#!/bin/bash

# GitHub Token Validation Script
# This script helps validate and test your GitHub token

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "GitHub Token Validation Script"
echo "================================================"

# Check if .env file exists
if [[ ! -f .env ]]; then
    print_error ".env file not found!"
    print_status "Please create .env file from .env.template"
    exit 1
fi

# Load environment variables
source .env

# Validate token format
if [[ -z "$GITHUB_TOKEN" ]]; then
    print_error "GITHUB_TOKEN is not set in .env file"
    exit 1
fi

if [[ ! "$GITHUB_TOKEN" =~ ^ghp_[a-zA-Z0-9]{36}$ ]] && [[ ! "$GITHUB_TOKEN" =~ ^github_pat_[a-zA-Z0-9_]{82}$ ]]; then
    print_warning "Token format doesn't match expected GitHub token patterns"
    print_status "Classic tokens start with 'ghp_' and are 40 characters total"
    print_status "Fine-grained tokens start with 'github_pat_' and are 93 characters total"
fi

# Test GitHub API access
print_status "Testing GitHub API access..."

if curl -s -f -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user >/dev/null 2>&1; then
    print_success "GitHub API access successful!"
    
    # Get user info
    USER_INFO=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
    USERNAME=$(echo "$USER_INFO" | grep -o '"login":"[^"]*' | cut -d'"' -f4)
    print_status "Authenticated as: $USERNAME"
    
    # Test repository access
    if [[ -n "$GITHUB_REPOSITORY" ]]; then
        print_status "Testing repository access: $GITHUB_REPOSITORY"
        
        if curl -s -f -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY" >/dev/null 2>&1; then
            print_success "Repository access confirmed!"
            
            # Test runner registration endpoint
            print_status "Testing runner registration endpoint..."
            REGISTRATION_URL="https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token"
            
            if curl -s -f -X POST -H "Authorization: token $GITHUB_TOKEN" "$REGISTRATION_URL" >/dev/null 2>&1; then
                print_success "Runner registration endpoint accessible!"
                print_success "All GitHub API tests passed! ✅"
            else
                print_error "Cannot access runner registration endpoint"
                print_status "Your token may not have 'workflow' permissions"
            fi
        else
            print_error "Cannot access repository: $GITHUB_REPOSITORY"
            print_status "Check if the repository name is correct and token has access"
        fi
    else
        print_warning "GITHUB_REPOSITORY not set"
    fi
    
else
    print_error "GitHub API access failed!"
    print_status "This could be due to:"
    print_status "  1. Invalid or expired token"
    print_status "  2. Network connectivity issues"
    print_status "  3. Token doesn't have required permissions"
    
    # Show token info (safely)
    TOKEN_PREFIX="${GITHUB_TOKEN:0:10}"
    TOKEN_LENGTH=${#GITHUB_TOKEN}
    print_status "Token starts with: ${TOKEN_PREFIX}..."
    print_status "Token length: $TOKEN_LENGTH characters"
    
    exit 1
fi

echo
print_success "Token validation completed successfully!"
print_status "You can now run: ./runner.sh setup"
