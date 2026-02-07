from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv

import models
import schemas
import auth
from database import engine, get_db

load_dotenv()

# Create database tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="TODO App API", version="1.0.0")

# Get CORS origins from environment
cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== AUTH ENDPOINTS ====================

@app.post("/api/auth/register", response_model=schemas.UserResponse)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    """
    Register a new user with secure password hashing.
    Data is stored in SQLite database with bcrypt password hashing.
    """
    try:
        # Check if user already exists
        existing_user = db.query(models.User).filter(
            (models.User.username == user.username) | (models.User.email == user.email)
        ).first()
        
        if existing_user:
            raise HTTPException(status_code=400, detail="Username or email already registered")
        
        # Hash the password using bcrypt
        hashed_password = auth.get_password_hash(user.password)
        
        # Create new user
        db_user = models.User(
            username=user.username,
            email=user.email,
            full_name=user.full_name or user.username,
            hashed_password=hashed_password,
            is_active=True,
            dark_mode=False
        )
        
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        
        return db_user
        
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Registration error: {str(e)}")

@app.post("/api/auth/login", response_model=schemas.TokenResponse)
def login(credentials: schemas.LoginRequest, db: Session = Depends(get_db)):
    """Login user and return JWT tokens"""
    user = db.query(models.User).filter(models.User.username == credentials.username).first()
    
    if not user or not auth.verify_password(credentials.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = auth.create_access_token({"user_id": user.id, "username": user.username})
    refresh_token = auth.create_refresh_token({"user_id": user.id})
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@app.get("/api/auth/me", response_model=schemas.UserResponse)
def get_current_user_info(current_user: models.User = Depends(auth.get_current_user)):
    return current_user

@app.put("/api/auth/profile", response_model=schemas.UserResponse)
def update_profile(
    update: schemas.UserUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if update.full_name is not None:
        current_user.full_name = update.full_name
    if update.dark_mode is not None:
        current_user.dark_mode = update.dark_mode
    
    db.commit()
    db.refresh(current_user)
    return current_user

# ==================== TODO ENDPOINTS ====================

@app.post("/api/todos", response_model=schemas.TodoResponse)
def create_todo(
    todo: schemas.TodoCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    db_todo = models.Todo(
        **todo.dict(),
        owner_id=current_user.id
    )
    db.add(db_todo)
    db.commit()
    db.refresh(db_todo)
    return db_todo

@app.get("/api/todos", response_model=list[schemas.TodoResponse])
def get_todos(
    skip: int = 0,
    limit: int = 100,
    completed: bool = None,
    priority: str = None,
    category_id: int = None,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(models.Todo).filter(models.Todo.owner_id == current_user.id)
    
    if completed is not None:
        query = query.filter(models.Todo.completed == completed)
    if priority:
        query = query.filter(models.Todo.priority == priority)
    if category_id:
        query = query.filter(models.Todo.category_id == category_id)
    
    return query.offset(skip).limit(limit).all()

@app.get("/api/todos/{todo_id}", response_model=schemas.TodoWithCollaborators)
def get_todo(
    todo_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or (todo.owner_id != current_user.id and current_user not in todo.collaborators):
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo

@app.put("/api/todos/{todo_id}", response_model=schemas.TodoResponse)
def update_todo(
    todo_id: int,
    update: schemas.TodoUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    for key, value in update.dict(exclude_unset=True).items():
        setattr(todo, key, value)
    
    db.commit()
    db.refresh(todo)
    return todo

@app.delete("/api/todos/{todo_id}")
def delete_todo(
    todo_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    db.delete(todo)
    db.commit()
    return {"message": "Todo deleted"}

# ==================== CATEGORY ENDPOINTS ====================

@app.post("/api/categories", response_model=schemas.CategoryResponse)
def create_category(
    category: schemas.CategoryCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    db_category = models.Category(
        **category.dict(),
        owner_id=current_user.id
    )
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

@app.get("/api/categories", response_model=list[schemas.CategoryResponse])
def get_categories(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(models.Category).filter(models.Category.owner_id == current_user.id).all()

# ==================== TAG ENDPOINTS ====================

@app.post("/api/todos/{todo_id}/tags/{tag_id}")
def add_tag_to_todo(
    todo_id: int,
    tag_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    tag = db.query(models.Tag).filter(models.Tag.id == tag_id).first()
    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")
    
    if tag not in todo.tags:
        todo.tags.append(tag)
        db.commit()
    
    return {"message": "Tag added"}

@app.delete("/api/todos/{todo_id}/tags/{tag_id}")
def remove_tag_from_todo(
    todo_id: int,
    tag_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    tag = db.query(models.Tag).filter(models.Tag.id == tag_id).first()
    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")
    
    if tag in todo.tags:
        todo.tags.remove(tag)
        db.commit()
    
    return {"message": "Tag removed"}

# ==================== COLLABORATION ENDPOINTS ====================

@app.post("/api/todos/{todo_id}/share/{user_id}")
def share_todo(
    todo_id: int,
    user_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user not in todo.collaborators:
        todo.collaborators.append(user)
        db.commit()
    
    return {"message": "Todo shared"}

@app.delete("/api/todos/{todo_id}/share/{user_id}")
def unshare_todo(
    todo_id: int,
    user_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user in todo.collaborators:
        todo.collaborators.remove(user)
        db.commit()
    
    return {"message": "Todo unshared"}

# ==================== COMMENT ENDPOINTS ====================

@app.post("/api/todos/{todo_id}/comments")
def add_comment(
    todo_id: int,
    comment: schemas.CommentCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or (todo.owner_id != current_user.id and current_user not in todo.collaborators):
        raise HTTPException(status_code=404, detail="Todo not found")
    
    db_comment = models.Comment(
        content=comment.content,
        author_id=current_user.id,
        todo_id=todo_id
    )
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return db_comment

# ==================== NOTIFICATION ENDPOINTS ====================

@app.get("/api/notifications", response_model=list[schemas.NotificationResponse])
def get_notifications(
    skip: int = 0,
    limit: int = 50,
    read: bool = None,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(models.Notification).filter(models.Notification.user_id == current_user.id)
    
    if read is not None:
        query = query.filter(models.Notification.read == read)
    
    return query.offset(skip).limit(limit).all()

@app.put("/api/notifications/{notification_id}/read")
def mark_notification_as_read(
    notification_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    notification = db.query(models.Notification).filter(
        models.Notification.id == notification_id
    ).first()
    if not notification or notification.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    notification.read = True
    db.commit()
    return {"message": "Notification marked as read"}

@app.put("/api/notifications/read-all")
def mark_all_as_read(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    db.query(models.Notification).filter(
        models.Notification.user_id == current_user.id,
        models.Notification.read == False
    ).update({"read": True})
    db.commit()
    return {"message": "All notifications marked as read"}

# ==================== EXPORT ENDPOINTS ====================

@app.get("/api/todos/export/json")
def export_todos_json(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todos = db.query(models.Todo).filter(models.Todo.owner_id == current_user.id).all()
    return {
        "user": current_user.username,
        "exported_at": datetime.utcnow().isoformat(),
        "todos": [schemas.TodoResponse.from_orm(todo).dict() for todo in todos]
    }

# Health check
@app.get("/api/health")
def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

@app.post("/api/auth/login", response_model=schemas.TokenResponse)
def login(username: str, password: str, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.username == username).first()
    if not user or not auth.verify_password(password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = auth.create_access_token({"user_id": user.id, "username": user.username})
    refresh_token = auth.create_refresh_token({"user_id": user.id})
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@app.get("/api/auth/me", response_model=schemas.UserResponse)
def get_current_user_info(current_user: models.User = Depends(auth.get_current_user)):
    return current_user

@app.put("/api/auth/profile", response_model=schemas.UserResponse)
def update_profile(
    update: schemas.UserUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if update.full_name is not None:
        current_user.full_name = update.full_name
    if update.dark_mode is not None:
        current_user.dark_mode = update.dark_mode
    
    db.commit()
    db.refresh(current_user)
    return current_user

# ==================== TODO ENDPOINTS ====================

@app.post("/api/todos", response_model=schemas.TodoResponse)
def create_todo(
    todo: schemas.TodoCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    db_todo = models.Todo(
        **todo.dict(),
        owner_id=current_user.id
    )
    db.add(db_todo)
    db.commit()
    db.refresh(db_todo)
    return db_todo

@app.get("/api/todos", response_model=list[schemas.TodoResponse])
def get_todos(
    skip: int = 0,
    limit: int = 100,
    completed: bool = None,
    priority: str = None,
    category_id: int = None,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(models.Todo).filter(models.Todo.owner_id == current_user.id)
    
    if completed is not None:
        query = query.filter(models.Todo.completed == completed)
    if priority:
        query = query.filter(models.Todo.priority == priority)
    if category_id:
        query = query.filter(models.Todo.category_id == category_id)
    
    return query.offset(skip).limit(limit).all()

@app.get("/api/todos/{todo_id}", response_model=schemas.TodoWithCollaborators)
def get_todo(
    todo_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or (todo.owner_id != current_user.id and current_user not in todo.collaborators):
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo

@app.put("/api/todos/{todo_id}", response_model=schemas.TodoResponse)
def update_todo(
    todo_id: int,
    update: schemas.TodoUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    for key, value in update.dict(exclude_unset=True).items():
        setattr(todo, key, value)
    
    db.commit()
    db.refresh(todo)
    return todo

@app.delete("/api/todos/{todo_id}")
def delete_todo(
    todo_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    db.delete(todo)
    db.commit()
    return {"message": "Todo deleted"}

# ==================== CATEGORY ENDPOINTS ====================

@app.post("/api/categories", response_model=schemas.CategoryResponse)
def create_category(
    category: schemas.CategoryCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    db_category = models.Category(
        **category.dict(),
        owner_id=current_user.id
    )
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

@app.get("/api/categories", response_model=list[schemas.CategoryResponse])
def get_categories(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(models.Category).filter(models.Category.owner_id == current_user.id).all()

# ==================== TAG ENDPOINTS ====================

@app.post("/api/todos/{todo_id}/tags/{tag_id}")
def add_tag_to_todo(
    todo_id: int,
    tag_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    tag = db.query(models.Tag).filter(models.Tag.id == tag_id).first()
    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")
    
    if tag not in todo.tags:
        todo.tags.append(tag)
        db.commit()
    
    return {"message": "Tag added"}

@app.delete("/api/todos/{todo_id}/tags/{tag_id}")
def remove_tag_from_todo(
    todo_id: int,
    tag_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    tag = db.query(models.Tag).filter(models.Tag.id == tag_id).first()
    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")
    
    if tag in todo.tags:
        todo.tags.remove(tag)
        db.commit()
    
    return {"message": "Tag removed"}

# ==================== COLLABORATION ENDPOINTS ====================

@app.post("/api/todos/{todo_id}/share/{user_id}")
def share_todo(
    todo_id: int,
    user_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user not in todo.collaborators:
        todo.collaborators.append(user)
        db.commit()
    
    return {"message": "Todo shared"}

@app.delete("/api/todos/{todo_id}/share/{user_id}")
def unshare_todo(
    todo_id: int,
    user_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or todo.owner_id != current_user.id:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user in todo.collaborators:
        todo.collaborators.remove(user)
        db.commit()
    
    return {"message": "Todo unshared"}

# ==================== COMMENT ENDPOINTS ====================

@app.post("/api/todos/{todo_id}/comments")
def add_comment(
    todo_id: int,
    comment: schemas.CommentCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo or (todo.owner_id != current_user.id and current_user not in todo.collaborators):
        raise HTTPException(status_code=404, detail="Todo not found")
    
    db_comment = models.Comment(
        content=comment.content,
        author_id=current_user.id,
        todo_id=todo_id
    )
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return db_comment

# ==================== NOTIFICATION ENDPOINTS ====================

@app.get("/api/notifications", response_model=list[schemas.NotificationResponse])
def get_notifications(
    skip: int = 0,
    limit: int = 50,
    read: bool = None,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(models.Notification).filter(models.Notification.user_id == current_user.id)
    
    if read is not None:
        query = query.filter(models.Notification.read == read)
    
    return query.offset(skip).limit(limit).all()

@app.put("/api/notifications/{notification_id}/read")
def mark_notification_as_read(
    notification_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    notification = db.query(models.Notification).filter(
        models.Notification.id == notification_id
    ).first()
    if not notification or notification.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    notification.read = True
    db.commit()
    return {"message": "Notification marked as read"}

@app.put("/api/notifications/read-all")
def mark_all_as_read(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    db.query(models.Notification).filter(
        models.Notification.user_id == current_user.id,
        models.Notification.read == False
    ).update({"read": True})
    db.commit()
    return {"message": "All notifications marked as read"}

# ==================== EXPORT ENDPOINTS ====================

@app.get("/api/todos/export/json")
def export_todos_json(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    todos = db.query(models.Todo).filter(models.Todo.owner_id == current_user.id).all()
    return {
        "user": current_user.username,
        "exported_at": datetime.utcnow().isoformat(),
        "todos": [schemas.TodoResponse.from_orm(todo).dict() for todo in todos]
    }

# Health check
@app.get("/api/health")
def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    # Get host and port from environment
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    debug = os.getenv("ENVIRONMENT", "development") == "development"
    uvicorn.run(app, host=host, port=port, reload=debug)
