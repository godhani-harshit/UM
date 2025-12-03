from uuid import UUID
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    access_token: str


class EmailLoginRequest(BaseModel):
    email: EmailStr 
    remember_me: bool 


class LoginResponse(BaseModel):
    access_token: str 
    refresh_token: str 
    token_type: str 
    expires_in: int 
    user_id: UUID
    email: EmailStr 
    name: Optional[str] 
    role: Optional[str]
    permissions: List[str] 
    workflows: List[str]


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class RefreshTokenResponse(BaseModel):
    access_token: str 
    token_type: str 
    expires_in: int



class UserProfile(BaseModel):
    user_id: UUID  
    email: EmailStr 
    name: Optional[str] 
    role: Optional[str]
    permissions: List[str] 
    workflows: List[str] 


class LogoutRequest(BaseModel):
    email: EmailStr


class LogoutResponse(BaseModel):
    message: str 
    user_email: EmailStr
    timestamp: datetime


class ErrorResponse(BaseModel):
    error: str 
    message: str 
    timestamp: datetime 