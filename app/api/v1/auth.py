from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Request
import httpx
from app.core.config import get_settings
from app.services.auth_service import (
    login_by_email,
    refresh_access_token,
    get_current_user_from_jwt,
    create_access_token,
)
from app.schemas.auth import (
    UserProfile,
    EmailLoginRequest,
    LogoutRequest,
    RefreshTokenRequest,  
    RefreshTokenResponse 
)
from app.core.logging import logger
from app.utils.security.azure_auth import validate_azure_token


router = APIRouter()

@router.get("/test-jwt", summary="Generate a temporary test JWT", tags=["debug"])
async def test_jwt():
    try:
        test_data = {
            "sub": "test@test.com",
            "user_id": "test-123",
            "name": "Test User",
            "role": "test_role",
            "workflows": ["test"],
            "permissions": ["test"],
        }

        access_token = create_access_token(data=test_data)

        return {
            "success": True,
            "message": "JWT generated successfully",
            "token_length": len(access_token),
            "token_preview": access_token[:50] + "..." 
        }

    except Exception as e:
        logger.exception("Error generating test JWT")
        return {
            "success": False,
            "error": str(e),
            "error_type": type(e).__name__
        }

@router.post(
    "/login",
    status_code=status.HTTP_200_OK,
    summary="Azure AD Login",
    description="Authenticate user using Azure AD Access Token and issue JWT access/refresh tokens"
)
async def login(request: Request, payload: EmailLoginRequest):
    """
    Azure-only login. User must send Azure access token.
    """
    try:
        logger.info("🔵 Azure login request received")

        # Token required
        if not getattr(payload, "azure_token", None):
            raise HTTPException(
                status_code=400,
                detail="azure_token is required for Azure login"
            )

        # Validate Azure token
        azure_payload = await validate_azure_token(payload.azure_token)

        # Extract user attributes
        email = azure_payload.get("preferred_username")
        name = azure_payload.get("name")

        if not email:
            raise HTTPException(status_code=400, detail="Azure token missing email")

        # Use your existing internal login logic (no structure change)
        lr = await login_by_email(email=email, remember_me=False, request=request)

        # Return SAME RESPONSE format exactly as original
        return {
            "access_token": lr.access_token,
            "refresh_token": lr.refresh_token,
            "token_type": lr.token_type,
            "expires_in": lr.expires_in,
            "user": {
                "user_id": str(lr.user_id),
                "email": lr.email,
                "name": name or lr.name,
                "role": lr.role,
                "permissions": lr.permissions,
                "workflows": lr.workflows,
                "is_active": True,
                "created_at": None,
                "last_login": None,
            },
        }

    except HTTPException as ex:
        logger.warning(f"⚠️ Azure login failed: {ex.detail}")
        raise ex
    except Exception as ex:
        logger.exception("💥 Unexpected error during Azure login")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error during Azure login"
        )


@router.post(
    "/refresh",
    response_model=RefreshTokenResponse,
    status_code=status.HTTP_200_OK,
    summary="Refresh access token",
    description="Get a new access token using a valid refresh token"
)
async def refresh_token(payload: RefreshTokenRequest):
    """
    Refresh access token using a valid refresh token.

    **Request Body**
    - `refresh_token`: Valid refresh token

    **Response**
    - `access_token`: Newly generated access token
    - `refresh_token`: (optional—only if you return new one)
    - `token_type`: Always "bearer"
    - `expires_in`: Token expiry in seconds

    **Possible Errors**
    - `401`: Invalid or expired refresh token
    - `500`: Internal server error
    """
    try:
        logger.info("🔄 Token refresh request received")

        # Refresh the token using your internal service
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
    status_code=status.HTTP_200_OK,
    summary="Azure AD Logout",
    description="Logs the user out from Azure AD only"
)
async def azure_logout(payload: LogoutRequest):
    """
    Logout user ONLY from Azure AD.

    - No database calls
    - No internal logout_user()
    - No JWT handling
    - Only Azure AD logout request
    """
    try:
        tenant_id = get_settings()["AZURE_AD_TENANT_ID"]

        azure_logout_url = (
            f"https://login.microsoftonline.com/"
            f"{tenant_id}/oauth2/v2.0/logout"
        )

        logger.info(f"🔵 Azure AD logout initiated for {payload.email}")

        async with httpx.AsyncClient() as client:
            await client.get(azure_logout_url, timeout=5)

        logger.info("🔵 Azure AD logout triggered successfully")

        return {
            "message": "Azure logout successful",
            "user_email": payload.email,
            "timestamp": datetime.utcnow().isoformat()
        }

    except Exception as ex:
        logger.exception("💥 Azure logout failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Azure logout failed"
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