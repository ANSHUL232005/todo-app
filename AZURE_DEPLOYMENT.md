# Production Deployment Guide - Azure with HTTPS

This guide walks you through deploying your TODO application to Azure with global HTTPS access, PostgreSQL database, and Let's Encrypt SSL certificates.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture Overview](#architecture-overview)
3. [Step-by-Step Deployment](#step-by-step-deployment)
4. [Domain Setup](#domain-setup)
5. [SSL/TLS Certificate](#ssltls-certificate)
6. [Environment Variables](#environment-variables)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- **Azure Account**: Create one at https://azure.microsoft.com
- **Azure CLI**: Install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- **Docker**: Already installed and working
- **Git**: For version control (optional)
- **Domain Name**: (Optional - can use Azure-provided domain initially)

### Verify Prerequisites

```bash
# Check Azure CLI
az version

# Check Docker
docker -v

# Verify you're logged into Azure
az account show
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure App Service                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Nginx Reverse Proxy (Port 80/443)            │   │
│  │  - SSL/TLS Termination (Let's Encrypt)              │   │
│  │  - Rate Limiting & Security Headers                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                   │
│          ┌────────────────┼────────────────┐                 │
│          │                │                │                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Frontend    │  │  Backend     │  │  PostgreSQL  │       │
│  │  (React)     │  │  (FastAPI)   │  │  Database    │       │
│  │  Port 3000   │  │  Port 8000   │  │  Port 5432   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                           │
                    ┌──────────────┐
                    │  User's      │
                    │  Domain with │
                    │  DNS pointing│
                    │  to Azure IP │
                    └──────────────┘
```

## Step-by-Step Deployment

### Phase 1: Azure Setup

#### 1.1 Login to Azure

```bash
az login
```

This opens a browser for authentication. After login, verify:

```bash
az account show
```

#### 1.2 Create Resource Group

```bash
# Define variables
RESOURCE_GROUP="todo-rg"
APP_SERVICE="todo-app"
CONTAINER_REGISTRY="todoregistry"
LOCATION="eastus"
POSTGRES_PASSWORD=$(openssl rand -base64 32)  # Generate secure password

# Create resource group
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"
```

#### 1.3 Create Azure Container Registry

```bash
# Create ACR (Azure Container Registry)
az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_REGISTRY" \
  --sku Basic \
  --admin-enabled true

# Get credentials
REGISTRY_USERNAME=$(az acr credential show \
  --name "$CONTAINER_REGISTRY" \
  --query "username" -o tsv)

REGISTRY_PASSWORD=$(az acr credential show \
  --name "$CONTAINER_REGISTRY" \
  --query "passwords[0].value" -o tsv)

REGISTRY_URL="${CONTAINER_REGISTRY}.azurecr.io"

echo "Registry URL: $REGISTRY_URL"
echo "Username: $REGISTRY_USERNAME"
```

#### 1.4 Create PostgreSQL Database

```bash
# Create PostgreSQL server
az postgres flexible-server create \
  --resource-group "$RESOURCE_GROUP" \
  --name "${APP_SERVICE}-db" \
  --location "$LOCATION" \
  --admin-user "todouser" \
  --admin-password "$POSTGRES_PASSWORD" \
  --sku-name Standard_B2s \
  --tier Burstable \
  --storage-size 32 \
  --version 15

# Create database
az postgres flexible-server db create \
  --resource-group "$RESOURCE_GROUP" \
  --server-name "${APP_SERVICE}-db" \
  --database-name "tododb"

# Store connection string
POSTGRES_HOST="${APP_SERVICE}-db.postgres.database.azure.com"
DATABASE_URL="postgresql://todouser:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/tododb"

echo "Database Host: $POSTGRES_HOST"
echo "Database URL: $DATABASE_URL"
```

#### 1.5 Create App Service Plan

```bash
# Create App Service Plan (Linux with Docker support)
az appservice plan create \
  --name "${APP_SERVICE}-plan" \
  --resource-group "$RESOURCE_GROUP" \
  --sku B2 \
  --is-linux
```

**Cost Note**: 
- Free tier (F1): Limited, suitable for testing only
- B1 (Basic): ~£40/month, suitable for low-traffic production
- B2 (Basic): ~£80/month, suitable for medium traffic
- S1 (Standard): ~£80/month, recommended for production

For production, recommend **B2 or higher**.

#### 1.6 Create Web App

```bash
# Create Web App
az webapp create \
  --resource-group "$RESOURCE_GROUP" \
  --plan "${APP_SERVICE}-plan" \
  --name "$APP_SERVICE" \
  --deployment-container-image-name-user "$REGISTRY_USERNAME" \
  --deployment-container-image-name-password "$REGISTRY_PASSWORD" \
  --deployment-container-image-name "$REGISTRY_URL/todo-app:latest"

# Get the app URL
APP_URL="https://${APP_SERVICE}.azurewebsites.net"
echo "App URL: $APP_URL"
```

### Phase 2: Docker Image Build & Push

#### 2.1 Build Docker Images

```bash
# Login to Azure Container Registry
az acr login --name "$CONTAINER_REGISTRY"

# Build backend image
docker build -t "$REGISTRY_URL/todo-backend:latest" ./backend

# Build frontend image
docker build -t "$REGISTRY_URL/todo-frontend:latest" ./frontend

# Build combined app image (optional, if using single container)
docker build -t "$REGISTRY_URL/todo-app:latest" .

# Verify images
docker images | grep "$REGISTRY_URL"
```

#### 2.2 Push to Container Registry

```bash
# Push images to Azure Container Registry
docker push "$REGISTRY_URL/todo-backend:latest"
docker push "$REGISTRY_URL/todo-frontend:latest"
docker push "$REGISTRY_URL/todo-app:latest"

# Verify in registry
az acr repository list --name "$CONTAINER_REGISTRY" --output table
```

### Phase 3: Application Configuration

#### 3.1 Update Environment Variables

Create/update `.env.production.secure`:

```env
# Security
SECRET_KEY=<generate-strong-key>
ENVIRONMENT=production
DEBUG=false

# Database (from Phase 1)
DATABASE_URL=<your-postgres-url-from-above>

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# JWT Tokens
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Logging
LOG_LEVEL=info
```

#### 3.2 Configure App Service Settings

```bash
# Set environment variables in App Service
az webapp config appsettings set \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE" \
  --settings \
    DATABASE_URL="$DATABASE_URL" \
    SECRET_KEY="<your-secret-key>" \
    ENVIRONMENT="production" \
    DEBUG="false" \
    CORS_ORIGINS="https://yourdomain.com"
```

#### 3.3 Configure Container Settings

```bash
# Set container configuration
az webapp config container set \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE" \
  --docker-custom-image-name "$REGISTRY_URL/todo-app:latest" \
  --docker-registry-server-url "https://$REGISTRY_URL" \
  --docker-registry-server-user "$REGISTRY_USERNAME" \
  --docker-registry-server-password "$REGISTRY_PASSWORD"

# Enable continuous deployment from registry
az webapp deployment container config \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE" \
  --enable-cd true
```

### Phase 4: Domain Setup (Optional)

#### 4.1 Buy a Domain

Options:
- **Namecheap**: $0.88/year (promo) - https://www.namecheap.com
- **GoDaddy**: Starting at $1.99/year - https://www.godaddy.com
- **Azure Domains**: Available through Azure portal
- **Route 53** (AWS): Professional tier

#### 4.2 Point Domain to Azure

1. Get Azure App Service IP address:
```bash
az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE" \
  --query "defaultHostName"
```

2. In your domain registrar:
   - Create an ALIAS record pointing to the Azure app
   - Or create an A record pointing to the Azure IP address
   
3. Add custom domain to App Service:
```bash
az webapp config hostname add \
  --resource-group "$RESOURCE_GROUP" \
  --webapp-name "$APP_SERVICE" \
  --hostname "yourdomain.com"
```

### Phase 5: SSL/TLS Certificate (Let's Encrypt)

#### 5.1 Automated SSL with App Service

```bash
# Add custom domain SSL certificate
az webapp config ssl bind \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE" \
  --certificate-thumbprint <your-cert-thumbprint> \
  --ssl-type SNI
```

#### 5.2 Using Certbot (for manual setup)

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com

# Certificate will be at:
# /etc/letsencrypt/live/yourdomain.com/fullchain.pem
# /etc/letsencrypt/live/yourdomain.com/privkey.pem

# Auto-renewal (runs twice daily)
sudo certbot renew --dry-run
```

#### 5.3 Configure in Nginx

Update `nginx.prod.conf`:

```nginx
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/ssl/key.pem;
```

## Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/tododb` |
| `SECRET_KEY` | JWT secret key (min 32 chars) | Generate with: `openssl rand -base64 32` |
| `ENVIRONMENT` | App environment | `production` |
| `CORS_ORIGINS` | Allowed origins (comma-separated) | `https://yourdomain.com` |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBUG` | `false` | Enable debug mode |
| `LOG_LEVEL` | `info` | Logging level (debug, info, warning, error) |
| `POSTGRES_PASSWORD` | `change-me` | PostgreSQL password |
| `API_HOST` | `0.0.0.0` | API listen address |
| `API_PORT` | `8000` | API port |

### Generate Secure Secret Key

```bash
# Linux/Mac
openssl rand -base64 32

# Windows (PowerShell)
$bytes = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32)
[Convert]::ToBase64String($bytes)

# Or use online generator (not recommended for production)
```

## Monitoring & Maintenance

### Check Application Logs

```bash
# Stream logs from App Service
az webapp log tail \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE"

# View Docker logs
docker logs <container-id>
```

### Monitor Database

```bash
# Connect to PostgreSQL
psql "postgresql://todouser:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/tododb"

# Check database size
SELECT pg_database.datname, 
       pg_size_pretty(pg_database_size(pg_database.datname)) 
FROM pg_database 
ORDER BY pg_database_size(pg_database.datname);
```

### Scale Up/Down

```bash
# Change SKU (scale up)
az appservice plan update \
  --name "${APP_SERVICE}-plan" \
  --resource-group "$RESOURCE_GROUP" \
  --sku S1

# Scale out (multiple instances)
az appservice plan update \
  --name "${APP_SERVICE}-plan" \
  --resource-group "$RESOURCE_GROUP" \
  --number-of-workers 3
```

## Troubleshooting

### Application Not Accessible

```bash
# Check app status
az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE" \
  --query "state"

# Check container status
az container logs \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE"

# Restart app
az webapp restart \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE"
```

### Database Connection Issues

```bash
# Verify database is running
az postgres flexible-server show \
  --resource-group "$RESOURCE_GROUP" \
  --name "${APP_SERVICE}-db"

# Check firewall rules (if needed)
az postgres flexible-server firewall-rule create \
  --resource-group "$RESOURCE_GROUP" \
  --name "${APP_SERVICE}-db" \
  --rule-name "AllowAppService" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255
```

### SSL Certificate Issues

```bash
# Check certificate status
openssl s_client -connect yourdomain.com:443 -showcerts

# Verify domain is bound correctly
az webapp config hostname list \
  --resource-group "$RESOURCE_GROUP" \
  --webapp-name "$APP_SERVICE"
```

## Cost Optimization

1. **Use Free Tier for Development**
   ```bash
   az appservice plan create \
     --sku FREE \
     --is-linux
   ```

2. **Auto-Scale Based on Metrics**
   ```bash
   az monitor autoscale-settings create \
     --resource-group "$RESOURCE_GROUP" \
     --name "${APP_SERVICE}-autoscale"
   ```

3. **Use Azure Key Vault for Secrets**
   - Avoid storing passwords in environment files
   - Rotate secrets regularly

4. **Enable Caching**
   - Leverage Nginx caching for static assets
   - Use CDN for global distribution

## Security Best Practices

1. ✅ Always use HTTPS (Let's Encrypt)
2. ✅ Enable MFA on Azure account
3. ✅ Use strong, unique passwords
4. ✅ Rotate secrets regularly
5. ✅ Keep Docker images updated
6. ✅ Use private container registry
7. ✅ Enable CORS restrictions
8. ✅ Monitor access logs regularly
9. ✅ Use Azure Key Vault for secrets
10. ✅ Enable audit logging

## Support & Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)

---

**Last Updated**: 2024
**Version**: 1.0
