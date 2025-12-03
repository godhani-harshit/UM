from uuid import UUID
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, EmailStr, Field


class UserOut(BaseModel):
    user_id: UUID 
    email: EmailStr
    name: Optional[str] = None
    role: Optional[str] = None
    permissions: List[str] = Field(default_factory=list)
    workflows: List[str] = Field(default_factory=list)
    is_active: bool = True
    created_at: Optional[datetime] = None
    last_login: Optional[datetime] = None


class Pagination(BaseModel):
    page: int
    page_size: int
    total_items: int
    total_pages: int
    has_next: bool
    has_previous: bool


class UserListResponse(BaseModel):
    users: List[UserOut]
    pagination: Pagination