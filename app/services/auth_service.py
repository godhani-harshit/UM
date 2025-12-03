from datetime import datetime, timedelta
from typing import Dict, List, Optional
from fastapi import HTTPException, Depends, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.future import select
from jose import jwt, JWTError
import os

from app.core.database import get_sync_database_url
from app.models.user import User
from app.utils.security.azure_auth import validate_azure_token
from app.models.role import Role
from app.models.workflow import Workflow
from app.models.role_workflows import RoleWorkflow  
from app.models.role_permissions import RolePermission  
from app.models.permission import Permission
from app.services.activity_log_service import (
    log_login_failed,
    log_login_success,
    log_auth_event,
)
from app.schemas.auth import LoginResponse, RefreshTokenResponse


# JWT Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "change-this-in-production")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_HOURS = int(os.getenv("ACCESS_TOKEN_EXPIRE_HOURS", "8"))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "7"))

security = HTTPBearer()

# ============================================================
# JWT TOKEN GENERATION
# ============================================================


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(hours=ACCESS_TOKEN_EXPIRE_HOURS))

    to_encode.update({
        "exp": expire,
        "iat": datetime.utcnow(),
        "type": "access",
    })

    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)

    to_encode.update({
        "exp": expire,
        "iat": datetime.utcnow(),
        "type": "refresh",
    })

    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def decode_jwt_token(token: str) -> Dict:
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except JWTError:
        raise HTTPException(status_code=401, detail="Could not validate credentials")


# ============================================================
# LOGIN VIA AZURE TOKEN → ISSUE JWT TOKENS
# ============================================================


async def validate_azure_token_and_get_user(azure_access_token: str, request: Request) -> LoginResponse:
    client_ip = request.client.host if request.client else "unknown"
    user_agent = request.headers.get("user-agent", "unknown")
    extracted_email = None

    try:
        async with get_sync_database_url() as session:

            # Step 1 – Validate Azure token
            try:
                azure_payload = await validate_azure_token(azure_access_token)
            except Exception as e:
                await log_login_failed(
                    email="unknown",
                    reason="Azure token validation failed",
                    ip_address=client_ip,
                    user_agent=user_agent,
                )
                raise HTTPException(status_code=401, detail="Invalid Azure AD access token")

            extracted_email = (
                azure_payload.get("preferred_username")
                or azure_payload.get("userPrincipalName")
                or azure_payload.get("email")
                or azure_payload.get("upn")
            )

            if not extracted_email:
                await log_login_failed(
                    email="unknown",
                    reason="Azure token missing email field",
                    ip_address=client_ip,
                    user_agent=user_agent,
                )
                raise HTTPException(400, "Azure token missing required email field")

            # Step 2 – Get user
            result = await session.execute(select(User).where(User.email == extracted_email))
            user = result.scalar_one_or_none()

            if not user:
                await log_login_failed(
                    email=extracted_email,
                    reason="User not registered",
                    ip_address=client_ip,
                    user_agent=user_agent,
                )
                raise HTTPException(401, "User not registered in UM system")

            if not user.is_active:
                await log_login_failed(
                    email=extracted_email,
                    reason="User inactive",
                    ip_address=client_ip,
                    user_agent=user_agent,
                )
                raise HTTPException(403, "User account is inactive")

            roles = [role.role_key for role in user.roles] if user.roles else []
            primary_role = roles[0] if roles else None

            permissions = await get_permissions_for_roles(roles)
            workflows = await get_workflows_for_roles(roles)

            # Step 3 – Issue tokens
            token_data = {
                "sub": user.email,
                "user_id": str(user.id),
                "name": user.full_name,
                "role": primary_role,
                "workflows": workflows,
                "permissions": permissions,
            }

            access_token = create_access_token(token_data)
            refresh_token = create_refresh_token({"sub": user.email})

            # HIPAA log
            await log_login_success(
                user_id=user.id,
                ip_address=client_ip,
                user_agent=user_agent,
                roles=roles,
                workflows=workflows,
            )

            return LoginResponse(
                access_token=access_token,
                refresh_token=refresh_token,
                token_type="bearer",
                expires_in=get_access_expiry_seconds(),
                user_id=user.id,
                email=user.email,
                name=user.full_name,
                role=primary_role,
                permissions=permissions,
                workflows=workflows,
            )

    except HTTPException:
        raise

    except Exception as e:
        await log_login_failed(
            email=extracted_email or "unknown",
            reason=f"Unexpected error: {str(e)}",
            ip_address=client_ip,
            user_agent=user_agent,
        )
        raise HTTPException(500, "Internal server error during authentication")


# ============================================================
# JWT VALIDATION FOR PROTECTED ROUTES
# ============================================================


async def get_current_user_from_jwt(credentials: HTTPAuthorizationCredentials = Depends(security)) -> Dict:
    token = credentials.credentials
    payload = decode_jwt_token(token)

    if payload.get("type") != "access":
        raise HTTPException(401, "Invalid token type")

    email = payload.get("sub")
    if not email:
        raise HTTPException(401, "Invalid token payload")

    return {
        "email": email,
        "user_id": payload.get("user_id"),
        "name": payload.get("name"),
        "role": payload.get("role"),
        "workflows": payload.get("workflows", []),
        "permissions": payload.get("permissions", []),
    }


# ============================================================
# REFRESH TOKEN
# ============================================================


async def refresh_access_token(refresh_token: str) -> RefreshTokenResponse:
    payload = decode_jwt_token(refresh_token)

    if payload.get("type") != "refresh":
        raise HTTPException(401, "Invalid refresh token type")

    email = payload.get("sub")
    if not email:
        raise HTTPException(401, "Invalid refresh token payload")

    async with get_sync_database_url() as session:
        result = await session.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()

        if not user or not user.is_active:
            raise HTTPException(401, "User not found or inactive")

        roles = [role.role_key for role in user.roles] if user.roles else []
        permissions = await get_permissions_for_roles(roles)
        workflows = await get_workflows_for_roles(roles)

        token_data = {
            "sub": user.email,
            "user_id": str(user.id),
            "name": user.full_name,
            "role": roles[0] if roles else None,
            "workflows": workflows,
            "permissions": permissions,
        }

        new_access_token = create_access_token(token_data)

        return RefreshTokenResponse(
            access_token=new_access_token,
            token_type="bearer",
            expires_in=get_access_expiry_seconds(),
        )


# ============================================================
# EMAIL-ONLY LOGIN
# ============================================================


async def login_by_email(email: str, remember_me: bool, request: Request) -> LoginResponse:
    client_ip = request.client.host if request.client else "unknown"
    user_agent = request.headers.get("user-agent", "unknown")

    async with get_sync_database_url() as session:
        result = await session.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()

        if not user:
            await log_login_failed(
                email=email,
                reason="User not registered",
                ip_address=client_ip,
                user_agent=user_agent,
            )
            raise HTTPException(401, "User not found")

        if not user.is_active:
            await log_login_failed(
                email=email,
                reason="User inactive",
                ip_address=client_ip,
                user_agent=user_agent,
            )
            raise HTTPException(403, "User inactive")

        roles = [role.role_key for role in user.roles] if user.roles else []
        primary_role = roles[0] if roles else None

        permissions = await get_permissions_for_roles(roles)
        workflows = await get_workflows_for_roles(roles)

        custom_hours = 24 * 30 if remember_me else ACCESS_TOKEN_EXPIRE_HOURS
        expires_delta = timedelta(hours=custom_hours)

        token_data = {
            "sub": user.email,
            "user_id": str(user.id),
            "name": user.full_name,
            "role": primary_role,
            "workflows": workflows,
            "permissions": permissions,
        }

        access_token = create_access_token(token_data, expires_delta)
        refresh_token = create_refresh_token({"sub": user.email})

        await log_login_success(
            user_id=user.id,
            ip_address=client_ip,
            user_agent=user_agent,
            roles=roles,
            workflows=workflows,
        )

        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=get_access_expiry_seconds(custom_hours),
            user_id=user.id,
            email=user.email,
            name=user.full_name,
            role=primary_role,
            permissions=permissions,
            workflows=workflows,
        )


# ============================================================
# LOGOUT (STATELESS)
# ============================================================


async def logout_user(email: str, request: Request) -> Dict:
    client_ip = request.client.host if request.client else "unknown"
    user_agent = request.headers.get("user-agent", "unknown")

    async with get_sync_database_url() as session:
        result = await session.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(404, "User not found")

        await log_auth_event(
            user_id=user.id,
            action="LOGOUT",
            success=True,
            ip_address=client_ip,
            user_agent=user_agent,
            details={"email": email, "event": "user_logout"},
        )

        return {
            "message": "Logged out successfully",
            "user_email": email,
            "timestamp": datetime.utcnow().isoformat(),
        }


# ============================================================
# HELPERS
# ============================================================


async def get_workflows_for_roles(roles: List[str]) -> List[str]:
    if not roles:
        return []
    async with get_sync_database_url() as session:
        result = await session.execute(
            select(Workflow.workflow_key)
            .join(RoleWorkflow, RoleWorkflow.workflow_id == Workflow.id)
            .join(Role, RoleWorkflow.role_id == Role.id)
            .where(
                Role.role_key.in_(roles),
                Workflow.deleted == "n",
                RoleWorkflow.deleted == "n",
            )
            .distinct()
        )
        return list(result.scalars().all())


async def get_permissions_for_roles(roles: List[str]) -> List[str]:
    if not roles:
        return []
    async with get_sync_database_url() as session:
        result = await session.execute(
            select(Permission.permission_key)
            .join(RolePermission, RolePermission.permission_id == Permission.id)
            .join(Role, RolePermission.role_id == Role.id)
            .where(
                Role.role_key.in_(roles),
                Permission.deleted == "n",
                RolePermission.deleted == "n",
                RolePermission.can_read == True,
            )
            .distinct()
        )
        return list(result.scalars().all())


def get_access_expiry_seconds(hours: Optional[int] = None) -> int:
    hrs = hours or ACCESS_TOKEN_EXPIRE_HOURS
    return hrs * 3600