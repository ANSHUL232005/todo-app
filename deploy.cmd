@echo off
REM Automated Netlify + Railway Deployment Helper
REM This script guides you through deploying to Railway (backend) and Netlify (frontend)

echo.
echo ==========================================
echo TODO App - Netlify + Railway Quick Deploy
echo ==========================================
echo.

REM Step 1: Check GitHub
echo Step 1: Create GitHub Repository
echo   1. Go to https://github.com/new
echo   2. Create repository named "todo-app"
echo   3. Paste your GitHub username here:
set /p GITHUB_USER=GitHub Username: 

REM Step 2: Push to GitHub
echo.
echo Step 2: Pushing to GitHub...
git add .
git commit -m "Deploy TODO app to Railway + Netlify"
git branch -M main
git remote add origin https://github.com/%GITHUB_USER%/todo-app.git

echo.
echo Step 3: Enter your GitHub Personal Access Token
echo   - Go to https://github.com/settings/tokens
echo   - Create token with 'repo' scope
echo   - Paste it here (characters will be hidden):
echo.
setlocal enabledelayedexpansion
for /f "delims=" %%a in ('powershell -Command "$pw = Read-Host \"GitHub Token\" -AsSecureString; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($pw); [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)"') do set "TOKEN=%%a"

REM Git push with token
git push -u origin main -u origin main

echo.
echo ==========================================
echo GitHub push complete!
echo ==========================================
echo.

REM Step 4: Deploy to Railway
echo.
echo Step 4: Deploy Backend to Railway
echo   1. Go to https://railway.app/login
echo   2. Click "New Project" ^> "Deploy from GitHub repo"
echo   3. Select "%GITHUB_USER%/todo-app"
echo   4. Add PostgreSQL database
echo   5. Set environment variables:
echo      - DATABASE_URL ^(auto-generated^)
echo      - SECRET_KEY=^(generate: python -c "import secrets; print(secrets.token_urlsafe(32))"^)
echo      - ENVIRONMENT=production
echo      - DEBUG=false
echo   6. Get your backend URL and save it
echo.
pause Press any key once Railway backend is deployed...

set /p RAILWAY_URL=Enter your Railway backend URL (e.g., https://todo-api.railway.app): 

REM Step 5: Deploy to Netlify
echo.
echo Step 5: Deploy Frontend to Netlify
echo   1. Go to https://netlify.com/drop
echo   2. Click "New site from Git"
echo   3. Choose GitHub and select "%GITHUB_USER%/todo-app"
echo   4. Go to "Site settings" ^> "Build & deploy" ^> "Environment"
echo   5. Add environment variable:
echo      - VITE_API_URL=%RAILWAY_URL%/api
echo   6. Click "Deploy"
echo.
pause Press any key once Netlify frontend is deployed...

set /p NETLIFY_URL=Enter your Netlify site URL (e.g., https://your-site.netlify.app): 

REM Step 6: Update backend CORS
echo.
echo Step 6: Update Backend CORS
echo   1. Go to Railway dashboard
echo   2. Select your FastAPI service
echo   3. Update environment variable:
echo      - CORS_ORIGINS=%NETLIFY_URL%
echo   4. Redeploy
echo.
pause Press any key once CORS is updated...

REM Done
echo.
echo ==========================================
echo Deployment Complete!
echo ==========================================
echo.
echo Frontend: %NETLIFY_URL%
echo Backend:  %RAILWAY_URL%/api
echo Health:   %RAILWAY_URL%/api/health
echo.
echo Go to %NETLIFY_URL% and test your app!
echo.
pause
