# Quick Start Guide for TODO Project

## Windows Users

### Quick Setup (Automated)
1. Double-click `setup.bat`
2. Follow the prompts

### Manual Setup

**Terminal 1 - Backend:**
```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
python main.py
```

**Terminal 2 - Frontend:**
```powershell
cd frontend
npm install
npm run dev
```

## macOS/Linux Users

### Quick Setup (Automated)
```bash
chmod +x setup.sh
./setup.sh
```

### Manual Setup

**Terminal 1 - Backend:**
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm install
npm run dev
```

## Access the Application

Once both servers are running:
- **Web**: Open browser to `http://localhost:3000`
- **API Documentation**: Visit `http://localhost:8000/docs`

## Create Test Account

1. Click "Sign up" on the login page
2. Fill in your details:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `password123`
3. Start creating todos!

## First Steps

1. **Create a Todo**: Click "Add Todo" and fill in details
2. **Set Priority**: Choose Low, Medium, High, or Urgent
3. **Add Due Date**: Set when the todo should be completed
4. **Mark Complete**: Click the circle icon to mark as done
5. **View Stats**: Check the sidebar for statistics
6. **Dark Mode**: Go to Settings → Appearance to toggle

## Troubleshooting

### Backend won't start
```bash
cd backend
pip install -r requirements.txt --upgrade
python main.py
```

### Frontend won't start
```bash
cd frontend
npm install --legacy-peer-deps
npm run dev
```

### Port conflicts
- Backend (port 8000): Edit `backend/main.py` last line
- Frontend (port 3000): Edit `frontend/vite.config.ts`

### Database reset
```bash
rm backend/todo.db
python backend/main.py  # Will recreate
```

## Building for Distribution

```bash
cd frontend
npm run build:win   # Windows
npm run build:mac   # macOS
npm run build:linux # Linux
```

The executable will be in `frontend/dist/`
