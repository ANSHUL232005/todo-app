# Production Deployment Quick Start

Follow these steps to deploy your TODO app to Azure with HTTPS in under 30 minutes.

## Step 1: Prerequisites (2 minutes)

```bash
# Verify Docker is running
docker ps

# Verify Azure CLI installed
az --version

# Login to Azure (opens browser)
az login
```

## Step 2: Configure Variables (3 minutes)

Edit or create `.env.production.secure`:

```bash
# Generate secure secret key
openssl rand -base64 32  # Copy output to SECRET_KEY

# For Windows PowerShell:
# [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))

# Generate PostgreSQL password
openssl rand -base64 16  # Copy output to POSTGRES_PASSWORD
```

**Update these in `.env.production.secure`:**
```
SECRET_KEY=<your-generated-key>
POSTGRES_PASSWORD=<your-generated-password>
CORS_ORIGINS=https://yourdomain.com
API_DOMAIN=yourdomain.com
```

## Step 3: Set Azure Deployment Variables (2 minutes)

```bash
# Define your deployment variables
export RESOURCE_GROUP="todo-rg"
export APP_SERVICE="todo-app"
export CONTAINER_REGISTRY="todoregistry"
export LOCATION="eastus"
export POSTGRES_PASSWORD="<your-generated-password>"

# Windows Command Prompt:
set RESOURCE_GROUP=todo-rg
set APP_SERVICE=todo-app
set CONTAINER_REGISTRY=todoregistry
set LOCATION=eastus
set POSTGRES_PASSWORD=<your-generated-password>

# Windows PowerShell:
$RESOURCE_GROUP = "todo-rg"
$APP_SERVICE = "todo-app"
$CONTAINER_REGISTRY = "todoregistry"
$LOCATION = "eastus"
$POSTGRES_PASSWORD = "<your-generated-password>"
```

## Step 4: Create Azure Resources (8 minutes)

### Option A: Automated (Recommended)

```bash
# Linux/Mac
bash azure-deploy.sh $RESOURCE_GROUP $APP_SERVICE $CONTAINER_REGISTRY

# Windows Command Prompt
azure-deploy.bat %RESOURCE_GROUP% %APP_SERVICE% %CONTAINER_REGISTRY%

# Windows PowerShell
& .\azure-deploy.bat $RESOURCE_GROUP $APP_SERVICE $CONTAINER_REGISTRY
```

### Option B: Manual

```bash
# Create Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Container Registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_REGISTRY \
  --sku Basic \
  --admin-enabled true

# Get registry credentials (save these!)
export REGISTRY_URL="${CONTAINER_REGISTRY}.azurecr.io"
export REGISTRY_USERNAME=$(az acr credential show \
  --name $CONTAINER_REGISTRY \
  --query "username" -o tsv)
export REGISTRY_PASSWORD=$(az acr credential show \
  --name $CONTAINER_REGISTRY \
  --query "passwords[0].value" -o tsv)

# Create PostgreSQL database
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name "${APP_SERVICE}-db" \
  --location $LOCATION \
  --admin-user "todouser" \
  --admin-password "$POSTGRES_PASSWORD" \
  --sku-name Standard_B2s \
  --tier Burstable \
  --version 15

# Create database
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name "${APP_SERVICE}-db" \
  --database-name "tododb"

# Create App Service Plan
az appservice plan create \
  --name "${APP_SERVICE}-plan" \
  --resource-group $RESOURCE_GROUP \
  --sku B2 \
  --is-linux

# Create Web App
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan "${APP_SERVICE}-plan" \
  --name $APP_SERVICE
```

## Step 5: Prepare Docker Images (5 minutes)

```bash
# Login to Azure Container Registry
az acr login --name $CONTAINER_REGISTRY

# Build backend image
docker build -t ${REGISTRY_URL}/todo-backend:latest ./backend

# Build frontend image
docker build -t ${REGISTRY_URL}/todo-frontend:latest ./frontend

# Push to registry
docker push ${REGISTRY_URL}/todo-backend:latest
docker push ${REGISTRY_URL}/todo-frontend:latest

# Verify
az acr repository list --name $CONTAINER_REGISTRY
```

## Step 6: Configure App Service (5 minutes)

```bash
# Set environment variables
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE \
  --settings \
    DATABASE_URL="postgresql://todouser:${POSTGRES_PASSWORD}@${APP_SERVICE}-db.postgres.database.azure.com:5432/tododb" \
    SECRET_KEY="<your-secret-key>" \
    ENVIRONMENT="production" \
    DEBUG="false" \
    CORS_ORIGINS="https://yourdomain.com"

# Configure container
az webapp config container set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE \
  --docker-custom-image-name "${REGISTRY_URL}/todo-app:latest" \
  --docker-registry-server-url "https://${REGISTRY_URL}" \
  --docker-registry-server-user "$REGISTRY_USERNAME" \
  --docker-registry-server-password "$REGISTRY_PASSWORD"

# Enable continuous deployment
az webapp deployment container config \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE \
  --enable-cd true
```

## Step 7: Configure Domain & SSL (5 minutes)

### If you don't have a domain yet:

```bash
# Get Azure-provided URL
az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE \
  --query defaultHostName -o tsv
# Access app at: https://todo-app.azurewebsites.net
```

### If you have a domain:

1. **Update DNS Records** (at your registrar)
   - Add CNAME or A record pointing to Azure
   - Wait 24-48 hours for propagation

2. **Add Custom Domain**
   ```bash
   az webapp config hostname add \
     --resource-group $RESOURCE_GROUP \
     --webapp-name $APP_SERVICE \
     --hostname yourdomain.com
   ```

3. **Add SSL Certificate**

   **Option A: Using Azure (Recommended)**
   ```bash
   # Azure will automatically provision free SSL via Microsoft
   ```

   **Option B: Using Let's Encrypt**
   ```bash
   # Install certbot
   sudo apt-get install certbot

   # Get certificate
   sudo certbot certonly --standalone -d yourdomain.com

   # Configure nginx.prod.conf with certificate path
   ```

## Step 8: Test Deployment (3 minutes)

```bash
# Get app URL
APP_URL=$(az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE \
  --query defaultHostName -o tsv)

echo "Testing: https://${APP_URL}"

# Test health endpoint
curl https://${APP_URL}/api/health

# Test frontend
curl https://${APP_URL}/

# Check logs
az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_SERVICE
```

## Verify Everything Works

1. **Frontend**: Open https://yourdomain.com in browser
2. **Register**: Create a new user account
3. **Login**: Log in with created account
4. **Create TODO**: Add a new TODO item
5. **Verify**: Check TODO appears in list

## Cost Summary

**Estimated Monthly Cost:**
- App Service Plan (B2): ~$80
- PostgreSQL Database (B2s): ~$25
- Container Registry: ~$5
- Storage: ~$5
- **Total**: ~$115/month

**Cost Optimization:**
- Use F1 (Free) for testing: $0
- Use B1 (Basic): ~$40/month
- Use auto-scaling to reduce peak usage
- Enable caching to reduce database queries

## Troubleshooting Quick Links

| Error | Solution |
|-------|----------|
| 503 Service Unavailable | Container not running - check `az webapp log tail` |
| Connection refused | Backend not listening - verify `0.0.0.0` in config |
| SSL certificate error | Wait 24h for DNS propagation or check CNAME |
| 401 Unauthorized | JWT token invalid - check SECRET_KEY |
| 500 Internal Error | Database issue - verify DATABASE_URL and connection |

## Important After Deployment

1. **Monitor First Week**
   - Check logs daily
   - Monitor error rate
   - Review user feedback

2. **Update Content**
   - Update documentation
   - Announce to users
   - Share feedback form

3. **Backup Strategy**
   - Enable automated PostgreSQL backups
   - Test backup restoration
   - Document recovery procedures

4. **Security Hardening**
   - Enable MFA on Azure account
   - Rotate secrets monthly
   - Review access logs weekly
   - Update dependencies regularly

## Next Steps

Refer to full documentation:
- **[AZURE_DEPLOYMENT.md]** - Complete deployment guide
- **[DEPLOYMENT_CHECKLIST.md]** - Pre/post deployment checklist
- **[Advanced Features]** - Email, caching, analytics

---

**Estimated Total Time**: 30 minutes
**Difficulty Level**: Intermediate
**Cost**: Starting at $40-50/month (B1 plan) to $500+/month (enterprise)
