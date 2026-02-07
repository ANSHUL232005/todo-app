# Docker Deployment Guide

## Overview

This guide provides instructions for deploying the TODO application using Docker and Docker Compose.

## Prerequisites

- **Docker** (v20.10+): [Install Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Docker Compose** (v1.29+): Included with Docker Desktop
- On Windows: Docker Desktop with WSL 2 backend recommended

## Quick Start (Local Docker)

### 1. Generate a Strong Secret Key

```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

Copy the output and save it for the next step.

### 2. Configure Environment

Edit `.env.production` and update:
```
SECRET_KEY=your-generated-secret-key-here
ENVIRONMENT=production
```

### 3. Build and Run

```bash
# Build images (first time only)
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 4. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

### 5. Verify Services are Running

```bash
# List running containers
docker ps

# Check backend health
curl http://localhost:8000/api/health

# Check frontend health
curl http://localhost:3000
```

## Docker Compose Structure

### Services

#### Backend Service
- **Image**: `todo-backend` (built from `backend/Dockerfile`)
- **Port**: 8000 (default)
- **Database**: SQLite at `/app/todo.db`
- **Health Check**: Every 30 seconds
- **Restart Policy**: Unless stopped
- **Environment**: Configured from `.env.production`

#### Frontend Service
- **Image**: `todo-frontend` (built from `frontend/Dockerfile`)
- **Port**: 3000 (default)
- **Build**: Multi-stage build (Node builder + lightweight serve)
- **Health Check**: Every 30 seconds
- **Depends On**: Backend service (waits for healthy backend before starting)
- **Restart Policy**: Unless stopped

### Volumes

- **backend_data**: Persists SQLite database across container restarts
- Location: `/app` inside backend container

### Networks

- **todo-network**: Custom bridge network connecting all services
- Allows containers to communicate by service name (e.g., `http://backend:8000`)

## Configuration

### Environment Variables (.env.production)

| Variable | Default | Purpose |
|----------|---------|---------|
| `SECRET_KEY` | CHANGE_ME | JWT signing key (must be strong) |
| `ALGORITHM` | HS256 | JWT algorithm |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | 30 | Access token lifetime |
| `REFRESH_TOKEN_EXPIRE_DAYS` | 7 | Refresh token lifetime |
| `ENVIRONMENT` | production | Application environment |
| `DATABASE_URL` | sqlite:///./todo.db | Database connection string |
| `BACKEND_PORT` | 8000 | Backend service port |
| `FRONTEND_PORT` | 3000 | Frontend service port |
| `API_HOST` | 0.0.0.0 | Backend bind address |

### Port Mapping

To use different ports, add to `docker-compose.yml` or override via environment:

```bash
# Override frontend port
FRONTEND_PORT=8080 docker-compose up -d
```

## Building Images Manually

### Backend
```bash
docker build -t todo-backend:latest ./backend
docker run -p 8000:8000 todo-backend:latest
```

### Frontend
```bash
docker build -t todo-frontend:latest ./frontend
docker run -p 3000:3000 todo-frontend:latest
```

## Useful Docker Commands

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View service logs
docker-compose logs backend
docker-compose logs frontend
docker-compose logs -f  # Follow logs

# Execute command in running container
docker exec -it todo-backend bash
docker exec -it todo-frontend sh

# Stop containers
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild images (after code changes)
docker-compose build --no-cache

# Run single service
docker-compose up -d backend

# Remove unused images/containers
docker system prune
```

## Production Deployment

### For Cloud Platforms (AWS, Azure, DigitalOcean, etc.)

1. **Push to Container Registry**
   ```bash
   # Example: Docker Hub
   docker tag todo-backend:latest yourusername/todo-backend:latest
   docker push yourusername/todo-backend:latest
   
   docker tag todo-frontend:latest yourusername/todo-frontend:latest
   docker push yourusername/todo-frontend:latest
   ```

2. **Update docker-compose.yml**
   ```yaml
   services:
     backend:
       image: yourusername/todo-backend:latest  # Use registry image
     frontend:
       image: yourusername/todo-frontend:latest  # Use registry image
   ```

3. **Deploy to Cloud**
   - Use platform's container deployment (ECS, App Engine, Container Instances)
   - Or use Docker Compose deployment features

### Security Hardening

Before production deployment:

```bash
# Generate strong secret key
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Update .env.production with strong SECRET_KEY

# Review exposed ports - only expose what's necessary
# Consider using a reverse proxy (nginx) in front of services

# Enable HTTPS with Let's Encrypt certificate
# Mount certificate in production docker-compose.yml
```

### Database Persistence

The SQLite database persists in the `backend_data` volume. To backup:

```bash
# Backup database
docker exec todo-backend cp todo.db /app/todo.db.backup

# Copy from container to host
docker cp todo-backend:/app/todo.db ./backups/todo.db
```

### Resource Limits

Add resource constraints to `docker-compose.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend

# Rebuild clean
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Port already in use
```bash
# Find process using port
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process or use different port
BACKEND_PORT=8001 docker-compose up -d
```

### Database errors
```bash
# Reset database (WARNING: data loss)
docker-compose down -v
docker-compose up -d

# Or copy fresh database
docker exec todo-backend rm todo.db
docker-compose restart backend
```

### Frontend can't reach backend
- Ensure both services are on same network (they are by default)
- Check `REACT_APP_API_URL` environment variable
- Verify backend is healthy: `docker-compose ps` (should show "Up")

### Rebuild after code changes
```bash
# Rebuild specific service
docker-compose build backend --no-cache
docker-compose up -d backend

# Or rebuild all
docker-compose build --no-cache
docker-compose up -d
```

## Monitoring Health

```bash
# Check service status
docker-compose ps

# View health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Check logs for errors
docker-compose logs --tail=50 -f
```

## Integration with CI/CD

For automated deployment with GitHub Actions:

```yaml
# .github/workflows/deploy.yml
name: Deploy to Docker
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and push
        run: |
          docker-compose build
          # Push to registry
          # Deploy to production
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com/)
- [Container Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Review `.env.production` configuration
3. Verify Docker installation: `docker --version && docker-compose --version`
4. Check port availability
5. Review this guide's troubleshooting section
