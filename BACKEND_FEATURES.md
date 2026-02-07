# Backend Files Summary

## Core Files
- **main.py** - FastAPI application with all API endpoints
- **models.py** - SQLAlchemy database models
- **schemas.py** - Pydantic validation schemas
- **auth.py** - JWT authentication and password hashing
- **database.py** - Database connection and session management

## API Endpoints

### Authentication (5 endpoints)
- POST /api/auth/register
- POST /api/auth/login
- GET /api/auth/me
- PUT /api/auth/profile

### Todo Operations (5 endpoints)
- GET /api/todos (with filters)
- POST /api/todos
- GET /api/todos/{id}
- PUT /api/todos/{id}
- DELETE /api/todos/{id}

### Categories (2 endpoints)
- POST /api/categories
- GET /api/categories

### Tags (2 endpoints)
- POST /api/todos/{todo_id}/tags/{tag_id}
- DELETE /api/todos/{todo_id}/tags/{tag_id}

### Collaboration (2 endpoints)
- POST /api/todos/{todo_id}/share/{user_id}
- DELETE /api/todos/{todo_id}/share/{user_id}

### Comments (1 endpoint)
- POST /api/todos/{todo_id}/comments

### Notifications (3 endpoints)
- GET /api/notifications
- PUT /api/notifications/{id}/read
- PUT /api/notifications/read-all

### Data Export (1 endpoint)
- GET /api/todos/export/json

## Database Models (7 models)
- User - User accounts and preferences
- Todo - Todo items with all metadata
- Category - Todo categories
- Tag - Todo tags
- Comment - Todo comments
- Notification - User notifications
- Association tables for M2M relationships

## Features Implemented
✅ JWT Authentication with refresh tokens
✅ Secure password hashing (bcrypt)
✅ Todo CRUD operations
✅ Priority levels (low, medium, high, urgent)
✅ Due dates with UTC timestamps
✅ Recurring tasks (daily, weekly, monthly, yearly)
✅ Categories for organization
✅ Tags for flexible categorization
✅ Collaboration (share todos, comments)
✅ Notifications system
✅ Data export (JSON)
✅ CORS enabled for cross-origin requests
✅ SQLite database (upgradeable to PostgreSQL)
