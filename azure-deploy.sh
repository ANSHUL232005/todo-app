#!/bin/bash

# Azure Deployment Script for TODO App
# This script deploys the application to Azure App Service using Docker containers

set -e  # Exit on error

echo "=========================================="
echo "TODO App - Azure Deployment Script"
echo "=========================================="

# Configuration
RESOURCE_GROUP="${1:-todo-rg}"
APP_SERVICE="${2:-todo-app}"
CONTAINER_REGISTRY="${3:-todoregistry}"
ADMIN_USERNAME="${4:-azureuser}"
LOCATION="${5:-eastus}"

echo ""
echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  App Service: $APP_SERVICE"
echo "  Container Registry: $CONTAINER_REGISTRY"
echo "  Location: $LOCATION"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Login to Azure
echo "📝 Logging into Azure..."
az login

# Create resource group
echo "📦 Creating Resource Group: $RESOURCE_GROUP..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION"

# Create Azure Container Registry
echo "🔐 Creating Azure Container Registry: $CONTAINER_REGISTRY..."
az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_REGISTRY" \
    --sku Basic \
    --admin-enabled true

# Get registry credentials
echo "🔑 Getting Container Registry credentials..."
REGISTRY_USERNAME=$(az acr credential show \
    --name "$CONTAINER_REGISTRY" \
    --query "username" -o tsv)

REGISTRY_PASSWORD=$(az acr credential show \
    --name "$CONTAINER_REGISTRY" \
    --query "passwords[0].value" -o tsv)

REGISTRY_URL="${CONTAINER_REGISTRY}.azurecr.io"

echo "  Registry URL: $REGISTRY_URL"
echo "  Username: $REGISTRY_USERNAME"

# Create App Service Plan (Linux)
echo "📋 Creating App Service Plan..."
az appservice plan create \
    --name "${APP_SERVICE}-plan" \
    --resource-group "$RESOURCE_GROUP" \
    --sku B2 \
    --is-linux

# Create Web App
echo "🚀 Creating Web App: $APP_SERVICE..."
az webapp create \
    --resource-group "$RESOURCE_GROUP" \
    --plan "${APP_SERVICE}-plan" \
    --name "$APP_SERVICE" \
    --deployment-container-image-name-user "$REGISTRY_USERNAME" \
    --deployment-container-image-name-password "$REGISTRY_PASSWORD" \
    --deployment-container-image-name "$REGISTRY_URL/todo-app:latest"

# Configure container settings
echo "⚙️  Configuring container settings..."
az webapp config container set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_SERVICE" \
    --docker-custom-image-name "$REGISTRY_URL/todo-app:latest" \
    --docker-registry-server-url "https://$REGISTRY_URL" \
    --docker-registry-server-user "$REGISTRY_USERNAME" \
    --docker-registry-server-password "$REGISTRY_PASSWORD"

# Enable continuous deployment
echo "🔄 Enabling continuous deployment..."
az webapp deployment container config \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_SERVICE" \
    --enable-cd true

# Get the webhook URL
WEBHOOK_URL=$(az webapp deployment container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_SERVICE" \
    --query "serverUrl" -o tsv)

echo "🔗 Continuous Deployment Webhook URL:"
echo "   $WEBHOOK_URL"

# Create PostgreSQL Database
echo "🗄️  Creating Azure Database for PostgreSQL..."
az postgres flexible-server create \
    --resource-group "$RESOURCE_GROUP" \
    --name "${APP_SERVICE}-db" \
    --location "$LOCATION" \
    --admin-user "todouser" \
    --admin-password "$(openssl rand -base64 32)" \
    --sku-name Standard_B2s \
    --tier Burstable \
    --storage-size 32 \
    --version 15

# Create database
echo "📚 Creating application database..."
POSTGRES_HOST="${APP_SERVICE}-db.postgres.database.azure.com"
POSTGRES_USER="todouser"
POSTGRES_PASSWORD="$(openssl rand -base64 32)"

az postgres flexible-server db create \
    --resource-group "$RESOURCE_GROUP" \
    --server-name "${APP_SERVICE}-db" \
    --database-name "tododb"

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""
echo "App Service URL:" 
echo "  https://${APP_SERVICE}.azurewebsites.net"
echo ""
echo "Database Connection String:"
echo "  postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/tododb"
echo ""
echo "Next Steps:"
echo "  1. Update .env.production.secure with the PostgreSQL password"
echo "  2. Update CORS_ORIGINS with your domain"
echo "  3. Set up SSL certificate with Let's Encrypt"
echo "  4. Build and push Docker images to container registry:"
echo "     docker build -t ${REGISTRY_URL}/todo-app:latest ."
echo "     docker push ${REGISTRY_URL}/todo-app:latest"
echo ""
echo "Container Registry Credentials:"
echo "  URL: $REGISTRY_URL"
echo "  Username: $REGISTRY_USERNAME"
echo "  Password: $REGISTRY_PASSWORD"
echo ""
