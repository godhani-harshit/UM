from fastapi import APIRouter, Depends, HTTPException, status, Request
from app.services.auth_service import (
    login_by_email,
    refresh_access_token,
    logout_user,
    get_current_user_from_jwt,
    create_access_token,
)
from app.schemas.auth import (
    UserProfile,
    LoginRequest,
    LoginResponse,  # NEW - Add this schema
    EmailLoginRequest,
    LogoutRequest,
    LogoutResponse,
    RefreshTokenRequest,  # NEW - Add this schema
    RefreshTokenResponse  # NEW - Add this schema
)
from app.core.logging import logger

router = APIRouter()

# app/api/v1/auth.py - Add this temporarily for testing

@router.get("/test-jwt")
async def test_jwt():
    """Test JWT generation - TEMPORARY"""
    try:
        test_data = {
            "sub": "test@test.com",
            "user_id": "test-123",
            "name": "Test User",
            "role": "test_role",
            "workflows": ["test"],
            "permissions": ["test"]
        }
        
        access_token = create_access_token(data=test_data)
        
        return {
            "success": True,
            "token_length": len(access_token),
            "token_preview": access_token[:50]
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "error_type": type(e).__name__
        }

@router.post(
    "/login",
    status_code=status.HTTP_200_OK,
    summary="User login (email-only demo)",
    description="Authenticate user with email only and issue JWT access/refresh tokens"
)
async def login(request: Request, payload: EmailLoginRequest):
    """
    Email-only login for demo and internal flows. No password required.
    Returns JWT tokens and user profile.
    """
    try:
        logger.info("🔐 Email login request received")
        lr = await login_by_email(email=payload.email, remember_me=payload.remember_me, request=request)
        # Shape response as per spec (nest user object)
        return {
            "access_token": lr.access_token,
            "refresh_token": lr.refresh_token,
            "token_type": lr.token_type,
            "expires_in": lr.expires_in,
            "user": {
                "user_id": str(lr.user_id),
                "email": lr.email,
                "name": lr.name,
                "role": lr.role,
                "permissions": lr.permissions,
                "workflows": lr.workflows,
                "is_active": True,
                "created_at": None,
                "last_login": None,
            },
        }

    except HTTPException as ex:
        logger.warning(f"⚠️ Login failed: {ex.detail}")
        raise ex
    except Exception as ex:
        logger.exception("💥 Unexpected error during login")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error during login"
        )


@router.post(
    "/refresh",
    response_model=RefreshTokenResponse,
    status_code=status.HTTP_200_OK,
    summary="Refresh access token",
    description="Get new access token using refresh token"
)
async def refresh_token(payload: RefreshTokenRequest):
    """
    Refresh access token using refresh token.
    
    **Request:**
    - `refresh_token`: Valid refresh token
    
    **Response:**
    - `access_token`: New JWT access token
    - `token_type`: "bearer"
    
    **Errors:**
    - `401`: Invalid or expired refresh token
    - `500`: Internal server error
    """
    try:
        logger.info("🔄 Token refresh request received")
        
        new_tokens = await refresh_access_token(refresh_token=payload.refresh_token)
        
        logger.info("✅ Token refreshed successfully")
        return new_tokens

    except HTTPException as ex:
        logger.warning(f"⚠️ Token refresh failed: {ex.detail}")
        raise ex
    except Exception as ex:
        logger.exception("💥 Unexpected error during token refresh")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error during token refresh"
        )


@router.post(
    "/logout",
    response_model=LogoutResponse,
    status_code=status.HTTP_200_OK,
    summary="User logout",
    description="Log user logout event for compliance"
)
async def logout(request: Request, payload: LogoutRequest):
    """
    Log user logout for compliance.
    
    **Note**: With JWT tokens, actual logout is handled client-side by removing tokens.
    This endpoint logs the event for HIPAA/SOC2 compliance.
    
    **Request:**
    - `email`: Email of user to logout
    
    **Response:**
    - `message`: Success message
    - `user_email`: User email
    - `timestamp`: Logout timestamp
    
    **Errors:**
    - `404`: User not found
    - `500`: Internal server error
    """
    try:
        logger.info(f"🔓 Logout request for {payload.email}")
        
        result = await logout_user(email=payload.email, request=request)
        
        logger.info(f"✅ User {payload.email} logout logged successfully")
        return result

    except HTTPException as ex:
        logger.warning(f"⚠️ Logout failed: {ex.detail}")
        raise ex
    except Exception as ex:
        logger.exception("💥 Unexpected error during logout")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error during logout"
        )


@router.get(
    "/me",
    response_model=UserProfile,
    status_code=status.HTTP_200_OK,
    summary="Get current user profile",
    description="Retrieve authenticated user's profile using JWT token"
)
async def get_current_user_profile(
    current_user: dict = Depends(get_current_user_from_jwt)
):
    """
    Get profile information for the currently authenticated user.
    
    This endpoint requires a valid JWT token in the Authorization header:
    `Authorization: Bearer <your_jwt_token>`
    
    **Response:**
    - `user_id`: Unique user identifier
    - `email`: User email address
    - `name`: User full name
    - `role`: Primary user role
    - `permissions`: List of permission identifiers
    - `workflows`: List of accessible workflow identifiers
    
    **Errors:**
    - `401`: Invalid or expired JWT token
    - `500`: Internal server error
    """
    try:
        logger.info(f"👤 Fetching profile for user {current_user['email']}")
        return current_user

    except HTTPException as ex:
        logger.warning(f"⚠️ Profile fetch failed: {ex.detail}")
        raise ex
    except Exception as ex:
        logger.exception("💥 Unexpected error fetching user profile")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error fetching profile"
        )


@router.get(
    "/health",
    status_code=status.HTTP_200_OK,
    summary="Auth module health check",
    description="Check if authentication module is operational"
)
async def auth_health_check():
    """
    Health check endpoint for authentication module.
    """
    return {
        "status": "ok",
        "module": "authentication",
        "features": {
            "azure_ad": True,
            "jwt_tokens": True,  # NEW
            "token_refresh": True,  # NEW
            "local_auth": False,
            "session_management": False,
            "azure_token_validation": True
        }
    }