@echo off
REM Setup script for TODO Project

echo ===================================
echo TODO Project Setup
echo ===================================

REM Setup Backend
echo.
echo Setting up Backend...
cd backend

REM Check if venv exists
if not exist venv (
    echo Creating virtual environment...
    python -m venv venv
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing backend dependencies...
pip install -r requirements.txt

REM Create .env file if it doesn't exist
if not exist .env (
    echo Creating .env file from .env.example...
    copy .env.example .env
)

echo Backend setup complete!
echo To run backend: cd backend && venv\Scripts\activate && python main.py

REM Setup Frontend
echo.
echo Setting up Frontend...
cd ..\frontend

echo Installing frontend dependencies...
call npm install

echo Frontend setup complete!
echo To run frontend: cd frontend && npm run dev

echo.
echo ===================================
echo Setup Complete!
echo ===================================
echo.
echo Next steps:
echo 1. Terminal 1: cd backend && venv\Scripts\activate.bat && python main.py
echo 2. Terminal 2: cd frontend && npm run dev
echo.
pause
