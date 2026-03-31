<<<<<<< HEAD
# todo-app
=======
# Advanced TODO Application

A full-featured TODO application built with **Electron + React (Frontend)** and **FastAPI + Python (Backend)**.

## Features

### Core Features
- ✅ User authentication (Register/Login)
- ✅ Create, Read, Update, Delete (CRUD) todos
- ✅ Mark todos as complete/incomplete
- ✅ Delete todos

### Advanced Features
- 🏷️ **Tags & Categories** - Organize todos by categories and tags
- ⚡ **Priority Levels** - Set priority (Low, Medium, High, Urgent)
- 📅 **Due Dates** - Set and manage due dates with time tracking
- 🔄 **Recurring Tasks** - Create daily, weekly, monthly, or yearly recurring todos
- 👥 **Collaboration** - Share todos with other users
- 💬 **Comments** - Add comments to todos for collaboration
- 🔔 **Notifications** - Get notified about task updates and due dates
- 🌓 **Dark Mode** - Toggle between light and dark themes
- 📊 **Statistics** - View dashboard with todo stats
- 📤 **Data Export** - Export todos as JSON
- 🔐 **Authentication** - JWT-based secure authentication

## Project Structure

```
TODO Project/
├── backend/              # Python FastAPI backend
│   ├── main.py          # Main application
│   ├── models.py        # Database models
│   ├── schemas.py       # Pydantic schemas
│   ├── auth.py          # Authentication logic
│   ├── database.py      # Database configuration
│   └── requirements.txt  # Python dependencies
│
└── frontend/            # Electron + React frontend
    ├── src/
    │   ├── pages/       # Page components
    │   ├── components/  # React components
    │   ├── App.tsx      # Main app component
    │   └── store.ts     # State management
    ├── package.json
    └── vite.config.ts
```

## Installation & Setup

### Prerequisites
- Python 3.9+
- Node.js 16+ & npm
- Git

### Backend Setup

1. **Navigate to backend directory**
```bash
cd backend
```

2. **Create virtual environment**
```bash
python -m venv venv
```

3. **Activate virtual environment**
```bash
# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

4. **Install dependencies**
```bash
pip install -r requirements.txt
```

5. **Create .env file**
```bash
cp .env.example .env
```

Edit `.env` and configure if needed (optional for development):
```
DATABASE_URL=sqlite:///./todo.db
SECRET_KEY=your-secret-key-here-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
API_HOST=127.0.0.1
API_PORT=8000
```

6. **Run backend server**
```bash
python main.py
```

The backend will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to frontend directory** (in a new terminal)
```bash
cd frontend
```

2. **Install dependencies**
```bash
npm install
```

3. **Run development server**
```bash
npm run dev
```

The frontend will be available at `http://localhost:3000`

## Running the Application

### Development Mode

**Terminal 1 - Backend:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
python main.py
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm install
npm run dev
```

Open `http://localhost:3000` in your browser.

### Building Electron App

```bash
cd frontend
npm run build:win    # Windows
npm run build:mac    # macOS
npm run build:linux  # Linux
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user

## Deploying to Render (cloud)

1. Ensure your repo includes `render.yaml` and `.github/workflows/render_deploy.yml`.
2. Push main branch:
```bash
git add .
git commit -m "Add Render deploy automation"
git push origin main
```
3. Go to https://dashboard.render.com and import the GitHub repo.
4. Use existing `render.yaml` and set secrets:
   - `RENDER_API_KEY` in GitHub secrets for action if using automatic deploy.
5. Render will build and deploy both:
   - `backend` from `backend/Dockerfile`
   - `frontend` from `frontend/Dockerfile`

### Manual check after Render deploy
- `curl https://your-backend-service.onrender.com/api/health`
- `curl https://your-frontend-service.onrender.com`

> If you prefer, open `RENDER_DEPLOYMENT.md` for step-by-step instructions.
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user
- `PUT /api/auth/profile` - Update user profile

### Todos
- `GET /api/todos` - List all todos
- `POST /api/todos` - Create new todo
- `GET /api/todos/{id}` - Get todo details
- `PUT /api/todos/{id}` - Update todo
- `DELETE /api/todos/{id}` - Delete todo

### Categories
- `GET /api/categories` - List categories
- `POST /api/categories` - Create category

### Collaboration
- `POST /api/todos/{todo_id}/share/{user_id}` - Share todo
- `DELETE /api/todos/{todo_id}/share/{user_id}` - Unshare todo
- `POST /api/todos/{todo_id}/comments` - Add comment

### Notifications
- `GET /api/notifications` - List notifications
- `PUT /api/notifications/{id}/read` - Mark as read
- `PUT /api/notifications/read-all` - Mark all as read

### Data
- `GET /api/todos/export/json` - Export todos as JSON

## Database Models

### User
- username, email, password
- full_name, dark_mode preference
- Authentication and profile management

### Todo
- title, description, completed status
- priority (low, medium, high, urgent)
- due_date, recurrence pattern
- owner, category, tags
- comments, collaborators

### Category & Tag
- Organize and classify todos

### Notification
- Event tracking and user alerts

### Comment
- Collaboration on todos

## Technical Stack

### Backend
- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - ORM for database
- **Pydantic** - Data validation
- **JWT** - Authentication
- **SQLite/PostgreSQL** - Database

### Frontend
- **React 18** - UI framework
- **TypeScript** - Type safety
- **Electron** - Desktop application
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **Zustand** - State management
- **Axios** - API client

## Features Showcase

### Authentication
Secure login/registration with JWT tokens

### Todo Management
- Create todos with title, description, priority
- Set due dates and recurrence patterns
- Organize with categories and tags
- Quick complete/incomplete toggle

### Collaboration
- Share todos with other users
- Add comments to todos
- Real-time collaboration features

### Notifications
- Task due date reminders
- Collaboration notifications
- Comment notifications

### Dark Mode
- Full dark theme support
- Persisted user preference
- System-wide dark mode styling

### Data Export
- Export all todos as JSON
- Preserve structure and metadata

## Default Test Account

To test the app, you can register a new account or use:
- Username: `testuser`
- Password: `password123`

(Create via registration page)

## Development Tips

1. **Hot Reload**: Both frontend and backend support hot reload during development
2. **API Testing**: Use the FastAPI Swagger UI at `http://localhost:8000/docs`
3. **Database**: SQLite database file is created automatically at `backend/todo.db`
4. **Environment Variables**: Copy `.env.example` to `.env` for backend configuration

## Troubleshooting

### Port Already in Use
- Backend: Change `API_PORT` in `.env`
- Frontend: Modify `Vite` config in `frontend/vite.config.ts`

### CORS Issues
- Ensure backend CORS middleware is configured correctly

### Database Errors
- Delete `backend/todo.db` to reset database
- Check SQLAlchemy connection string in `.env`

## Future Enhancements

- Real-time WebSocket sync
- Mobile app (React Native)
- Cloud storage integration
- Advanced analytics
- Team workspaces
- Kanban board view
- Calendar integration

## License

MIT License

## Support

For issues or questions, please create an issue in the repository.
>>>>>>> abf3588 (Initial TODO app - ready for deployment to Railway + Netlify)
