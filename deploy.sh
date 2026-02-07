#!/bin/bash

# Docker Deployment Helper Script for TODO Application
# Usage: ./deploy.sh [command]
# Commands: build, up, down, logs, stop, restart, clean, rebuild

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_help() {
    cat << EOF

${GREEN}TODO Application - Docker Deployment Helper${NC}
=============================================

Usage: ./deploy.sh [command]

Commands:
  build       - Build Docker images
  up          - Start services (build if needed)
  down        - Stop services
  logs        - View service logs (follow mode)
  stop        - Stop services without removing
  restart     - Restart services
  clean       - Stop and remove containers/volumes
  rebuild     - Rebuild images from scratch
  status      - Show container status
  shell-be    - Open bash shell in backend container
  shell-fe    - Open shell in frontend container
  health      - Check service health
  setup       - Initial setup (generate secret key, build, etc.)
  help        - Show this help message

Examples:
  ./deploy.sh up
  ./deploy.sh logs
  ./deploy.sh rebuild
  ./deploy.sh setup

EOF
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        echo "Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}Error: Docker Compose is not installed${NC}"
        echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
}

cmd_build() {
    echo -e "${YELLOW}Building Docker images...${NC}"
    docker-compose build
    echo -e "${GREEN}Build complete!${NC}"
}

cmd_up() {
    check_docker
    echo -e "${YELLOW}Starting services...${NC}"
    docker-compose up -d
    sleep 2
    echo ""
    echo -e "${GREEN}Services started!${NC}"
    echo "Access them at:"
    echo "  Frontend: http://localhost:3000"
    echo "  Backend:  http://localhost:8000"
    echo "  API Docs: http://localhost:8000/docs"
    echo ""
    echo "View logs with: ./deploy.sh logs"
}

cmd_down() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker-compose down
    echo -e "${GREEN}Services stopped!${NC}"
}

cmd_logs() {
    check_docker
    echo -e "${YELLOW}Showing logs (Ctrl+C to exit)...${NC}"
    docker-compose logs -f
}

cmd_stop() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker-compose stop
    echo -e "${GREEN}Services stopped!${NC}"
}

cmd_restart() {
    echo -e "${YELLOW}Restarting services...${NC}"
    docker-compose restart
    sleep 2
    echo -e "${GREEN}Services restarted!${NC}"
}

cmd_clean() {
    echo -e "${YELLOW}Cleaning up containers and volumes...${NC}"
    docker-compose down -v
    echo -e "${GREEN}Cleanup complete!${NC}"
}

cmd_rebuild() {
    check_docker
    echo -e "${YELLOW}Rebuilding images from scratch...${NC}"
    docker-compose build --no-cache
    echo -e "${GREEN}Build complete!${NC}"
    echo "Run './deploy.sh up' to start services"
}

cmd_status() {
    echo ""
    echo -e "${YELLOW}Container Status:${NC}"
    echo "================="
    docker-compose ps
}

cmd_shell_backend() {
    echo -e "${YELLOW}Opening bash shell in backend container...${NC}"
    docker exec -it todo-backend bash
}

cmd_shell_frontend() {
    echo -e "${YELLOW}Opening shell in frontend container...${NC}"
    docker exec -it todo-frontend sh
}

cmd_health() {
    echo -e "${YELLOW}Checking service health...${NC}"
    echo ""
    
    if curl -s http://localhost:8000/api/health > /dev/null; then
        echo -e "${GREEN}✓ Backend is healthy${NC}"
    else
        echo -e "${RED}✗ Backend is not responding${NC}"
    fi
    
    if curl -s http://localhost:3000 > /dev/null; then
        echo -e "${GREEN}✓ Frontend is healthy${NC}"
    else
        echo -e "${RED}✗ Frontend is not responding${NC}"
    fi
    
    echo ""
    docker-compose ps
}

cmd_setup() {
    check_docker
    echo -e "${YELLOW}Setting up TODO Application with Docker${NC}"
    echo ""
    
    # Generate secret key
    echo -e "${YELLOW}Generating SECRET_KEY...${NC}"
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    echo "Generated: $SECRET_KEY"
    echo ""
    
    # Ask if user wants to update .env.production
    read -p "Do you want to update .env.production with this secret? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Update .env.production on macOS and Linux
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^SECRET_KEY=.*/SECRET_KEY=$SECRET_KEY/" .env.production
        else
            sed -i "s/^SECRET_KEY=.*/SECRET_KEY=$SECRET_KEY/" .env.production
        fi
        echo -e "${GREEN}Updated .env.production${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Building images...${NC}"
    cmd_build
    
    echo ""
    echo -e "${GREEN}Setup complete!${NC}"
    echo "Run './deploy.sh up' to start the application"
}

# Main script
if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

case "$1" in
    build)
        check_docker
        cmd_build
        ;;
    up)
        cmd_up
        ;;
    down)
        cmd_down
        ;;
    logs)
        cmd_logs
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    clean)
        cmd_clean
        ;;
    rebuild)
        cmd_rebuild
        ;;
    status)
        cmd_status
        ;;
    shell-be)
        cmd_shell_backend
        ;;
    shell-fe)
        cmd_shell_frontend
        ;;
    health)
        cmd_health
        ;;
    setup)
        cmd_setup
        ;;
    help)
        print_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        print_help
        exit 1
        ;;
esac
