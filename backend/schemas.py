from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from enum import Enum

class PriorityEnum(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"

class RecurrenceEnum(str, Enum):
    NONE = "none"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    YEARLY = "yearly"

# User Schemas
class UserBase(BaseModel):
    username: str
    email: str
    full_name: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    dark_mode: Optional[bool] = None

class UserResponse(UserBase):
    id: int
    is_active: bool
    dark_mode: bool
    created_at: datetime

    class Config:
        from_attributes = True

# Category Schemas
class CategoryBase(BaseModel):
    name: str
    color: Optional[str] = "#3B82F6"

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Tag Schemas
class TagBase(BaseModel):
    name: str

class TagCreate(TagBase):
    pass

class TagResponse(TagBase):
    id: int

    class Config:
        from_attributes = True

# Comment Schemas
class CommentBase(BaseModel):
    content: str

class CommentCreate(CommentBase):
    pass

class CommentResponse(CommentBase):
    id: int
    author_id: int
    todo_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Todo Schemas
class TodoBase(BaseModel):
    title: str
    description: Optional[str] = None
    priority: PriorityEnum = PriorityEnum.MEDIUM
    due_date: Optional[datetime] = None
    recurrence: RecurrenceEnum = RecurrenceEnum.NONE
    category_id: Optional[int] = None

class TodoCreate(TodoBase):
    pass

class TodoUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    completed: Optional[bool] = None
    priority: Optional[PriorityEnum] = None
    due_date: Optional[datetime] = None
    recurrence: Optional[RecurrenceEnum] = None
    category_id: Optional[int] = None

class TodoResponse(TodoBase):
    id: int
    completed: bool
    owner_id: int
    tags: List[TagResponse] = []
    category: Optional[CategoryResponse] = None
    comments: List[CommentResponse] = []
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class TodoWithCollaborators(TodoResponse):
    collaborators: List[UserResponse] = []

# Notification Schemas
class NotificationResponse(BaseModel):
    id: int
    title: str
    message: str
    type: str
    read: bool
    related_todo_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Auth Schemas
class TokenResponse(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str = "bearer"

class TokenData(BaseModel):
    user_id: int
    username: Optional[str] = None

class LoginRequest(BaseModel):
    username: str
    password: str
