"""
Authentication dependencies for FastAPI endpoints
"""
from fastapi import Depends
from app.schemas.auth import UserProfile
from app.services.auth_service import get_current_user_from_jwt


async def get_current_user(
    user_data: dict = Depends(get_current_user_from_jwt),
) -> UserProfile:
    """
    Dependency to get the current authenticated user from JWT token.

    This function wraps the auth service's get_current_user_from_jwt
    and converts the dict response to a UserProfile schema.

    Args:
        user_data: User data dict from JWT token validation

    Returns:
        UserProfile: The authenticated user's profile
    """
    return UserProfile(
        user_id=str(user_data.get("user_id", "")),
        email=user_data.get("email", ""),
        name=user_data.get("name", ""),
        role=user_data.get("role", ""),
        permissions=user_data.get("permissions", []),
        workflows=user_data.get("workflows", []),
    )
