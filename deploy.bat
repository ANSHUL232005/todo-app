@echo off
REM Docker Deployment Helper Script for TODO Application
REM Usage: deploy.bat [command]
REM Commands: build, up, down, logs, stop, restart, clean, rebuild

setlocal enabledelayedexpansion

REM Color codes
for /F %%A in ('echo prompt $H ^| cmd') do set "BS=%%A"

if "%1"=="" (
    echo.
    echo TODO Application - Docker Deployment Helper
    echo ============================================
    echo.
    echo Usage: deploy.bat [command]
    echo.
    echo Commands:
    echo   build       - Build Docker images
    echo   up          - Start services (build if needed^)
    echo   down        - Stop services
    echo   logs        - View service logs (follow mode^)
    echo   stop        - Stop services without removing
    echo   restart     - Restart services
    echo   clean       - Stop and remove containers/volumes
    echo   rebuild     - Rebuild images from scratch
    echo   status      - Show container status
    echo   shell-be    - Open bash shell in backend container
    echo   shell-fe    - Open shell in frontend container
    echo   help        - Show this help message
    echo.
    echo Examples:
    echo   deploy.bat up
    echo   deploy.bat logs
    echo   deploy.bat rebuild
    echo.
    goto end
)

if /i "%1"=="build" (
    echo Building Docker images...
    docker-compose build
    goto end
)

if /i "%1"=="up" (
    echo Starting services...
    docker-compose up -d
    echo.
    echo Services started! Access them at:
    echo   Frontend: http://localhost:3000
    echo   Backend:  http://localhost:8000
    echo   API Docs: http://localhost:8000/docs
    echo.
    echo View logs with: deploy.bat logs
    goto end
)

if /i "%1"=="down" (
    echo Stopping services...
    docker-compose down
    goto end
)

if /i "%1"=="logs" (
    echo Showing logs (Ctrl+C to exit)...
    docker-compose logs -f
    goto end
)

if /i "%1"=="stop" (
    echo Stopping services...
    docker-compose stop
    goto end
)

if /i "%1"=="restart" (
    echo Restarting services...
    docker-compose restart
    goto end
)

if /i "%1"=="clean" (
    echo Cleaning up containers and volumes...
    docker-compose down -v
    echo Cleanup complete!
    goto end
)

if /i "%1"=="rebuild" (
    echo Rebuilding images from scratch...
    docker-compose build --no-cache
    echo Build complete! Run 'deploy.bat up' to start services
    goto end
)

if /i "%1"=="status" (
    echo.
    echo Container Status:
    echo ================
    docker-compose ps
    goto end
)

if /i "%1"=="shell-be" (
    echo Opening bash shell in backend container...
    docker exec -it todo-backend bash
    goto end
)

if /i "%1"=="shell-fe" (
    echo Opening shell in frontend container...
    docker exec -it todo-frontend sh
    goto end
)

if /i "%1"=="help" (
    deploy.bat
    goto end
)

echo Unknown command: %1
echo Run 'deploy.bat' or 'deploy.bat help' for usage information
exit /b 1

:end
endlocal
