#!/bin/bash

# Setup script for TODO Project (macOS/Linux)

echo "==================================="
echo "TODO Project Setup"
echo "==================================="

# Setup Backend
echo ""
echo "Setting up Backend..."
cd backend

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

echo "Installing backend dependencies..."
pip install -r requirements.txt

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
fi

echo "Backend setup complete!"
echo "To run backend: cd backend && source venv/bin/activate && python main.py"

# Setup Frontend
echo ""
echo "Setting up Frontend..."
cd ../frontend

echo "Installing frontend dependencies..."
npm install

echo "Frontend setup complete!"
echo "To run frontend: cd frontend && npm run dev"

echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Terminal 1: cd backend && source venv/bin/activate && python main.py"
echo "2. Terminal 2: cd frontend && npm run dev"
