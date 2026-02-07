@echo off
REM Azure Deployment Script for TODO App (Windows)
REM This script deploys the application to Azure App Service using Docker containers

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo TODO App - Azure Deployment Script
echo ==========================================
echo.

REM Configuration
set "RESOURCE_GROUP=%1"
set "APP_SERVICE=%2"
set "CONTAINER_REGISTRY=%3"
set "LOCATION=%4"

if "%RESOURCE_GROUP%"=="" set "RESOURCE_GROUP=todo-rg"
if "%APP_SERVICE%"=="" set "APP_SERVICE=todo-app"
if "%CONTAINER_REGISTRY%"=="" set "CONTAINER_REGISTRY=todoregistry"
if "%LOCATION%"=="" set "LOCATION=eastus"

echo Configuration:
echo   Resource Group: %RESOURCE_GROUP%
echo   App Service: %APP_SERVICE%
echo   Container Registry: %CONTAINER_REGISTRY%
echo   Location: %LOCATION%
echo.

REM Check if Azure CLI is installed
where az >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Azure CLI is not installed. Please install it first:
    echo        https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
    exit /b 1
)

REM Login to Azure
echo Logging into Azure...
call az login

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to login to Azure
    exit /b 1
)

REM Create resource group
echo.
echo Creating Resource Group: %RESOURCE_GROUP%...
call az group create ^
    --name "%RESOURCE_GROUP%" ^
    --location "%LOCATION%"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create resource group
    exit /b 1
)

REM Create Azure Container Registry
echo.
echo Creating Azure Container Registry: %CONTAINER_REGISTRY%...
call az acr create ^
    --resource-group "%RESOURCE_GROUP%" ^
    --name "%CONTAINER_REGISTRY%" ^
    --sku Basic ^
    --admin-enabled true

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create container registry
    exit /b 1
)

REM Get registry credentials
echo.
echo Getting Container Registry credentials...
for /f "tokens=*" %%i in ('az acr credential show --name %CONTAINER_REGISTRY% --query "username" -o tsv') do set "REGISTRY_USERNAME=%%i"
for /f "tokens=*" %%i in ('az acr credential show --name %CONTAINER_REGISTRY% --query "passwords[0].value" -o tsv') do set "REGISTRY_PASSWORD=%%i"

set "REGISTRY_URL=%CONTAINER_REGISTRY%.azurecr.io"

echo   Registry URL: %REGISTRY_URL%
echo   Username: %REGISTRY_USERNAME%

REM Create App Service Plan (Linux)
echo.
echo Creating App Service Plan...
call az appservice plan create ^
    --name "%APP_SERVICE%-plan" ^
    --resource-group "%RESOURCE_GROUP%" ^
    --sku B2 ^
    --is-linux

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create app service plan
    exit /b 1
)

REM Create Web App
echo.
echo Creating Web App: %APP_SERVICE%...
call az webapp create ^
    --resource-group "%RESOURCE_GROUP%" ^
    --plan "%APP_SERVICE%-plan" ^
    --name "%APP_SERVICE%" ^
    --deployment-container-image-name "%REGISTRY_URL%/todo-app:latest"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create web app
    exit /b 1
)

REM Configure container settings
echo.
echo Configuring container settings...
call az webapp config container set ^
    --resource-group "%RESOURCE_GROUP%" ^
    --name "%APP_SERVICE%" ^
    --docker-custom-image-name "%REGISTRY_URL%/todo-app:latest" ^
    --docker-registry-server-url "https://%REGISTRY_URL%" ^
    --docker-registry-server-user "%REGISTRY_USERNAME%" ^
    --docker-registry-server-password "%REGISTRY_PASSWORD%"

REM Enable continuous deployment
echo.
echo Enabling continuous deployment...
call az webapp deployment container config ^
    --resource-group "%RESOURCE_GROUP%" ^
    --name "%APP_SERVICE%" ^
    --enable-cd true

echo.
echo ==========================================
echo ^✓ Deployment Setup Complete!
echo ==========================================
echo.
echo App Service URL: 
echo   https://%APP_SERVICE%.azurewebsites.net
echo.
echo Container Registry URL: %REGISTRY_URL%
echo Container Registry Username: %REGISTRY_USERNAME%
echo.
echo Next Steps:
echo   1. Build Docker image for production
echo   2. Push to Azure Container Registry
echo   3. Configure environment variables in App Service
echo   4. Set up domain and SSL certificate
echo.
pause
