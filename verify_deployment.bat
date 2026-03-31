@echo off
REM Auto-deploy verification script for Render (Windows)
REM Run this after deployment to verify all systems are healthy

setlocal enabledelayedexpansion

set BACKEND_URL=https://todo-backend.onrender.com
set FRONTEND_URL=https://todo-frontend.onrender.com

echo.
echo Verifying TODO App Deployment...
echo ==========================================

REM Test 1: Backend Health Check
echo.
set /p "=1. Backend Health Check... " <nul
for /f %%i in ('curl -s "%BACKEND_URL%/api/health"') do set HEALTH=%%i
if defined HEALTH (
    echo OK
    echo    Response: !HEALTH!
) else (
    echo FAILED
    exit /b 1
)

REM Test 2: Frontend Accessibility
echo.
set /p "=2. Frontend Accessibility... " <nul
for /f %%i in ('curl -s -o nul -w "%%{http_code}" "%FRONTEND_URL%"') do set FRONTEND_STATUS=%%i
if "%FRONTEND_STATUS%"=="200" (
    echo OK ^(HTTP 200^)
) else (
    echo WARNING ^(HTTP !FRONTEND_STATUS!^)
)

REM Test 3: Registration Endpoint
echo.
set /p "=3. Registration Endpoint... " <nul
for /f %%i in ('curl -s -X POST "%BACKEND_URL%/api/auth/register" -H "Content-Type: application/json" -d "{\"username\":\"test\",\"email\":\"test@example.com\",\"password\":\"Test123\"}" -w "%%{http_code}"') do set REG_CODE=%%i
if "%REG_CODE%"=="201" (
    echo OK
) else (
    echo Note: HTTP !REG_CODE!
)

REM Test 4: API Documentation
echo.
set /p "=4. API Docs ^(Swagger^)... " <nul
for /f %%i in ('curl -s -o nul -w "%%{http_code}" "%BACKEND_URL%/docs"') do set DOCS_STATUS=%%i
if "%DOCS_STATUS%"=="200" (
    echo OK
) else (
    echo WARNING ^(HTTP !DOCS_STATUS!^)
)

echo.
echo ==========================================
echo Deployment Verification Complete!
echo.
echo Access your app:
echo    Frontend: %FRONTEND_URL%
echo    Backend:  %BACKEND_URL%
echo    API Docs: %BACKEND_URL%/docs
echo.
