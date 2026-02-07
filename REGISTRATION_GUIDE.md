# Registration Guide - Quick Start

## Current Status

✅ **REGISTRATION IS READY**
- Backend API: Fully functional
- Database: SQLite at `backend/todo.db`
- Password Security: PBKDF2 hashing (passwords are safe)
- Frontend: Ready at http://localhost:3000

---

## Testing Registration

### Using the Web Browser

1. **Open the app**: http://localhost:3000
2. **Click "Register"** button
3. **Fill in the form**:
   - Username: `john_doe` (must be unique)
   - Email: `john@example.com` (must be unique)
   - Password: `SecurePass123!` (min 6 chars recommended)
   - Full Name: `John Doe`
4. **Click "Create Account"**
5. **Success**: You'll be logged in and see the dashboard

---

## Test Users

You can create your own, but try these examples:

```
User 1:
- Username: alice
- Email: alice@example.com
- Password: AlicePass123!

User 2:
- Username: bob  
- Email: bob@example.com
- Password: BobPass456!

User 3:
- Username: admin
- Email: admin@project.com
- Password: AdminSecure789!
```

---

## Using the API Directly (for developers)

### Register via curl
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPass123",
    "full_name": "Test User"
  }'
```

### Response (Success)
```json
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "full_name": "Test User",
  "is_active": true,
  "dark_mode": false,
  "created_at": "2026-02-07T12:34:56.789123"
}
```

---

## How Data is Stored

### Password Security
- ✓ Passwords are hashed using PBKDF2-SHA256
- ✓ Original password is NEVER stored
- ✓ Even administrators cannot see original passwords
- ✓ Users can reset via email verification

### User Data Location
```
c:\Users\HP\TODO Project\backend\todo.db
```

**File Contents:**
- Users table (usernames, hashed passwords, emails)
- Todos table (all todo items)
- Categories table
- Tags table
- Comments table
- Notifications table

### Who Can Access Data
- **Users**: Can access their own data only
- **Database administrators**: Can access database file
- **API**: Validates JWT tokens before returning data
- **Frontend**: Shows data only to authenticated users

---

## What's Protected

### .gitignore (Protected Files)
These files are NOT tracked in git (safe for production):
```
✗ .env              (Environment secrets)
✗ todo.db          (Database with user data)
✗ venv/            (Virtual environment)
✗ .env.local       (Local overrides)
```

### These files ARE tracked (safe to commit)
```
✓ models.py        (Database schema definition)
✓ auth.py          (Authentication logic)
✓ database.py      (Database configuration)
✓ main.py          (API endpoints)
✓ schemas.py       (Data validation)
```

---

## Security Features Enabled

- [x] Password hashing (PBKDF2)
- [x] JWT authentication
- [x] CORS enabled for development
- [x] SQL injection prevention (SQLAlchemy)
- [x] Environment variables for secrets
- [x] Database transactions for data integrity
- [x] Input validation (Pydantic schemas)
- [x] Error handling without exposing internals

---

## Next Steps

### For Testing Registration:
1. Start backend: `cd backend && python -m uvicorn main:app --reload`
2. Start frontend: Already running at http://localhost:3000
3. Register a new user in the browser
4. Login with the credentials
5. Create todos and test the app

### For Production:
1. Read `SECURITY_AND_DATA.md` (complete guide)
2. Change SECRET_KEY in `.env`
3. Set ENVIRONMENT=production
4. Use HTTPS
5. Set up database backups
6. Configure proper CORS settings

---

## Frequently Asked Questions

**Q: Where is user password stored?**
A: Only hashed password is stored in `backend/todo.db`. Original password is NEVER stored.

**Q: Can I see user passwords?**
A: No. Passwords are one-way hashed using PBKDF2. Even the database admin cannot retrieve original passwords.

**Q: Is the database encrypted?**
A: Database file is plain SQLite by default. You can enable encryption in `.env` or use Windows BitLocker.

**Q: Where should I backup user data?**
A: Copy `backend/todo.db` regularly to a safe location (external drive, cloud backup, etc.)

**Q: Can users delete their accounts?**
A: Yes, implement a DELETE /api/auth/profile endpoint (to be added)

**Q: How long are login sessions?**
A: 30 minutes for access token, 7 days for refresh token (configurable in `.env`)

---

## Environment Setup

### .env File Contents
```
DATABASE_URL=sqlite:///./todo.db
SECRET_KEY=your-super-secret-key-change-in-production-12345-abcde
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
API_HOST=127.0.0.1
API_PORT=8000
ENVIRONMENT=development
```

### Change Before Production
- [ ] SECRET_KEY → Use strong random value
- [ ] DATABASE_URL → Point to production database
- [ ] ENVIRONMENT → Set to "production"
- [ ] API_HOST → Set to production server
- [ ] CORS origins → Restrictive domains

---

## Database Access for Builders

### View All Users
```python
from database import SessionLocal
from models import User

db = SessionLocal()
users = db.query(User).all()
for user in users:
    print(f"ID: {user.id}, Username: {user.username}, Email: {user.email}")
db.close()
```

### View Specific User
```python
from database import SessionLocal
from models import User

db = SessionLocal()
user = db.query(User).filter(User.username == "john_doe").first()
if user:
    print(f"User: {user.username}, Email: {user.email}, Created: {user.created_at}")
db.close()
```

### Export All User Data
```python
from database import SessionLocal
from models import User
import json

db = SessionLocal()
users = db.query(User).all()
data = [
    {
        "id": u.id,
        "username": u.username,
        "email": u.email,
        "full_name": u.full_name,
        "created_at": u.created_at.isoformat()
    }
    for u in users
]
print(json.dumps(data, indent=2))
db.close()
```

---

**Registration is fully functional and secure! Test it now at http://localhost:3000**
