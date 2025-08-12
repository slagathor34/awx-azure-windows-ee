#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main setup function
setup_runner() {
    print_status "Starting GitHub Self-Hosted Runner setup..."
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running or accessible. Please start Docker."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
    
    # Check if .env file exists
    if [[ ! -f .env ]]; then
        print_warning ".env file not found"
        
        if [[ -f .env.template ]]; then
            print_status "Copying .env.template to .env"
            cp .env.template .env
            print_warning "Please edit .env file with your GitHub token and repository information"
            print_warning "Then run this script again"
            exit 1
        else
            print_error ".env.template not found. Please create .env file manually"
            exit 1
        fi
    fi
    
    # Source environment variables
    print_status "Loading environment variables..."
    source .env
    
    # Validate required environment variables
    if [[ -z "$GITHUB_TOKEN" ]] || [[ "$GITHUB_TOKEN" == "ghp_your_token_here" ]]; then
        print_error "GITHUB_TOKEN is not set or uses template value. Please update .env file"
        exit 1
    fi
    
    if [[ -z "$GITHUB_REPOSITORY" ]] || [[ "$GITHUB_REPOSITORY" == "your-username/your-repo" ]]; then
        print_error "GITHUB_REPOSITORY is not set or uses template value. Please update .env file"
        exit 1
    fi
    
    print_success "Environment variables loaded"
    
    # Test GitHub API access
    print_status "Testing GitHub API access..."
    if ! curl -s -f -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user >/dev/null; then
        print_error "Cannot access GitHub API. Please check your token"
        exit 1
    fi
    print_success "GitHub API access confirmed"
    
    # Clean up any existing containers
    print_status "Cleaning up existing containers..."
    docker-compose down --remove-orphans 2>/dev/null || true
    
    # Build and start the runner
    print_status "Building GitHub runner container..."
    docker-compose build --no-cache
    
    print_status "Starting GitHub runner..."
    docker-compose up -d
    
    # Wait for container to start
    print_status "Waiting for runner to initialize..."
    sleep 10
    
    # Check if container is running
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Container failed to start. Checking logs..."
        docker-compose logs
        exit 1
    fi
    
    # Check registration status
    print_status "Checking runner registration..."
    max_attempts=30
    attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if docker-compose exec -T github-runner test -f /home/runner/.runner 2>/dev/null; then
            registration_info=$(docker-compose exec -T github-runner cat /home/runner/.runner 2>/dev/null | grep -E "(agentId|agentName)" | head -2)
            if [[ -n "$registration_info" ]]; then
                print_success "Runner registered successfully!"
                echo "$registration_info"
                break
            fi
        fi
        
        ((attempt++))
        print_status "Waiting for registration... (attempt $attempt/$max_attempts)"
        sleep 5
    done
    
    if [[ $attempt -eq $max_attempts ]]; then
        print_error "Runner registration timed out. Checking logs..."
        docker-compose logs --tail=50 github-runner
        exit 1
    fi
    
    # Display final status
    print_success "GitHub Self-Hosted Runner setup complete!"
    echo
    print_status "Runner Status:"
    docker-compose ps
    echo
    print_status "To verify the runner in GitHub:"
    print_status "1. Go to: https://github.com/$GITHUB_REPOSITORY/settings/actions/runners"
    print_status "2. Look for runner: $RUNNER_NAME"
    echo
    print_status "Useful commands:"
    print_status "  View logs:     docker-compose logs -f"
    print_status "  Restart:       docker-compose restart"
    print_status "  Stop:          docker-compose down"
    print_status "  Status:        docker-compose ps"
    echo
    print_success "Setup completed successfully!"
}

# Function to show help
show_help() {
    echo "GitHub Self-Hosted Runner Quick Setup"
    echo
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  setup     Set up and start the GitHub runner (default)"
    echo "  stop      Stop the GitHub runner"
    echo "  restart   Restart the GitHub runner"
    echo "  status    Show runner status"
    echo "  logs      Show runner logs"
    echo "  cleanup   Remove all containers and volumes"
    echo "  help      Show this help message"
    echo
}

# Function to stop runner
stop_runner() {
    print_status "Stopping GitHub runner..."
    docker-compose down
    print_success "GitHub runner stopped"
}

# Function to restart runner
restart_runner() {
    print_status "Restarting GitHub runner..."
    docker-compose restart
    print_success "GitHub runner restarted"
}

# Function to show status
show_status() {
    print_status "GitHub Runner Status:"
    docker-compose ps
    echo
    
    if docker-compose ps | grep -q "Up"; then
        print_status "Runner Registration Info:"
        if docker-compose exec -T github-runner test -f /home/runner/.runner 2>/dev/null; then
            docker-compose exec -T github-runner cat /home/runner/.runner 2>/dev/null | grep -E "(agentId|agentName)"
        else
            print_warning "Runner not yet registered"
        fi
    else
        print_warning "Runner is not running"
    fi
}

# Function to show logs
show_logs() {
    print_status "Showing GitHub runner logs..."
    docker-compose logs -f
}

# Function to cleanup
cleanup_runner() {
    print_warning "This will remove all containers, networks, and volumes"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up GitHub runner..."
        docker-compose down -v --remove-orphans
        docker system prune -f
        print_success "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Main script logic
case "${1:-setup}" in
    "setup")
        setup_runner
        ;;
    "stop")
        stop_runner
        ;;
    "restart")
        restart_runner
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "cleanup")
        cleanup_runner
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
