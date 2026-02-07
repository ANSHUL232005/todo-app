# TODO App - Security & Data Storage Documentation

## Registration & Authentication Security

### Password Security
- **Algorithm**: PBKDF2-SHA256 (PKCS#5)
- **Hash Function**: Passwordless Storage - Only hashed passwords are saved
- **How it works**: 
  - User password is hashed using PBKDF2 before being stored in the database
  - Original password is NEVER stored in any file
  - When user logs in, entered password is hashed and compared with stored hash
  - Impossible to reverse the hash and get the original password

### JWT Authentication
- **Access Tokens**: 30-minute expiration (configurable in .env)
- **Refresh Tokens**: 7-day expiration (configurable in .env)
- **Algorithm**: HS256
- **Storage**: Tokens stored in browser's localStorage (secure location)

---

## Data Storage Architecture

### Database Location
```
c:\Users\HP\TODO Project\backend\todo.db
```

### Database Type
- **SQLite 3** - File-based, portable, secure
- **Auto-backup**: Create copies of todo.db for backup
- **Encryption** (optional): Can be added with SQLAlchemy extensions

### Database Tables

#### Users Table
```
- id: Unique user ID
- username: Unique username
- email: Unique email address
- hashed_password: PBKDF2 hashed password (NOT plain text)
- full_name: User's display name
- is_active: Account status
- dark_mode: User preference
- created_at: Registration timestamp
- updated_at: Last profile update timestamp
```

**Sample User Storage:**
```
ID: 1
Username: john_doe
Email: john@example.com
Hashed Password: $pbkdf2-sha256$....(encrypted, irreversible)
Full Name: John Doe
Created: 2026-02-07 06:13:36
```

#### Todos Table
```
- id: Todo ID
- title: Todo title
- description: Todo details
- completed: Status (true/false)
- priority: low/medium/high/urgent
- due_date: When todo is due
- owner_id: FK to Users (who owns this todo)
- created_at: When created
- updated_at: When last modified
```

#### Additional Tables
- **Categories**: For organizing todos
- **Tags**: For tagging todos
- **Comments**: For collaboration
- **Notifications**: For alerts
- **todo_tags**: Junction table for todo-tag relationships
- **todo_collaborators**: Junction table for sharing todos

---

## Secure Data Access

### For Developers/Builders Only

#### Protected Files in Project
These files are protected in `.gitignore` and should NOT be committed to version control:

```
☒ backend/.env                 (Environment secrets)
☒ backend/todo.db             (Database file with user data)
☒ backend/*.sqlite            (Any SQLite database files)
☒ backend/__pycache__/        (Compiled Python files)
☒ backend/venv/               (Virtual environment)
```

#### How to Access User Data (Builders)
1. **Direct Database Access**:
   ```bash
   cd backend
   python -c "from database import SessionLocal; from models import User; db = SessionLocal(); users = db.query(User).all(); print(users)"
   ```

2. **Export Endpoint** (for authenticated users):
   ```
   GET /api/todos/export/json
   Header: Authorization: Bearer <jwt_token>
   ```
   Returns user's todos in JSON format with all metadata

3. **Database File**:
   - Located: `c:\Users\HP\TODO Project\backend\todo.db`
   - Size: Grows with data
   - Backup: Copy this file to create snapshots

### Encryption at Rest
- Database file is not encrypted by default
- To add encryption: Install `sqlalchemy-utils` and enable SQLAlchemy encryption
- Or: Use Windows BitLocker for folder encryption

---

## Environment Variables (Security Config)

Location: `backend/.env`

```env
# Database
DATABASE_URL=sqlite:///./todo.db

# JWT Security (CHANGE THESE IN PRODUCTION!)
SECRET_KEY=your-super-secret-key-change-in-production-12345-abcde
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# API
API_HOST=127.0.0.1
API_PORT=8000

# Environment
ENVIRONMENT=development
```

### Production Checklist
- [ ] Change SECRET_KEY to a strong random value
- [ ] Set ENVIRONMENT=production
- [ ] Enable HTTPS in frontend
- [ ] Set CORS origins to specific domains
- [ ] Consider database encryption
- [ ] Set up database backups
- [ ] Use external SECRET management (AWS Secrets Manager, Vault, etc.)

---

## Registered Users Example

After registration, users are stored like:

```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "full_name": "John Doe",
  "is_active": true,
  "dark_mode": false,
  "created_at": "2026-02-07T06:13:36.307288",
  "hashed_password": "$pbkdf2-sha256$260000$abcdefg..." 
}
```

**Important**: The `hashed_password` field uses PBKDF2 encryption and CANNOT be reversed to get the original password.

---

## Data Privacy & GDPR

### User Rights
- **Right to Access**: Users can request their data export via `/api/todos/export/json`
- **Right to Delete**: Delete user endpoint should be implemented
- **Data Retention**: Define policy for deleted account data
- **Transparency**: Inform users about data collection

---

## Backup & Recovery

### Backup Process
```bash
# Backup database
copy backend\todo.db backend\todo.db.backup

# Restore from backup
copy backend\todo.db.backup backend\todo.db
```

### Regular Backups Recommended
- Daily automated backups
- Store on separate system
- Test restore procedures monthly

---

## API Endpoints for Registration

### Register New User
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "full_name": "John Doe"
}

Response (201):
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "full_name": "John Doe",
  "is_active": true,
  "dark_mode": false,
  "created_at": "2026-02-07T..."
}
```

### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "john_doe",
  "password": "SecurePass123!"
}

Response (200):
{
  "access_token": "eyJ0...",
  "token_type": "bearer",
  "refresh_token": "eyJ0..."
}
```

---

## Security Best Practices

1. ✓ Never store plain passwords
2. ✓ Use HTTPS in production
3. ✓ Rotate JWT secret regularly
4. ✓ Implement rate limiting on auth endpoints
5. ✓ Enable database backups
6. ✓ Use environment variables for secrets
7. ✓ Implement CSRF protection
8. ✓ Sanitize user inputs
9. ✓ Use parameterized queries (SQLAlchemy)
10. ✓ Implement proper error handling

---

## Files Location Reference

```
TODO Project/
├── backend/
│   ├── .env                  ← Secrets (DO NOT COMMIT)
│   ├── todo.db             ← User data database (DO NOT COMMIT)
│   ├── models.py           ← Database schema
│   ├── schemas.py          ← Data validation
│   ├── auth.py             ← Authentication logic
│   ├── database.py         ← Database connection
│   ├── main.py             ← API endpoints
│   ├── requirements.txt    ← Python dependencies
│   └── .gitignore         ← Prevents committing secrets
│
└── frontend/
    ├── src/
    │   ├── api.ts          ← API client
    │   ├── store.ts        ← State management
    │   └── ...
    └── ...
```

---

## Support

For security questions or implementation details, refer to the backend files:
- Authentication: `backend/auth.py`
- Database: `backend/database.py`
- Models: `backend/models.py`
- Settings: `backend/.env`
