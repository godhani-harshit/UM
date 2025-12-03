from typing import Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.future import select
from app.core.database import get_sync_database_url
from app.core.logging import logger
from app.models.user import User
from app.schemas.users import UserListResponse, UserOut, Pagination
from app.services.auth_service import get_current_user_from_jwt

router = APIRouter()


def _require_admin(current_user: dict):
    role = current_user.get("role")
    if role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="User does not have permission to access this resource")


@router.get("/users", response_model=UserListResponse, summary="List users (admin only)")
async def list_users(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    role: Optional[str] = Query(None),
    status_filter: Optional[str] = Query(None, alias="status"),
    current_user: dict = Depends(get_current_user_from_jwt),
):
    _require_admin(current_user)

    async with get_sync_database_url() as session:
        query = select(User)
        if role:
            # Filter by primary role name stored on user (fallback if roles M2M not populated)
            query = query.where(User.role_name == role)
        if status_filter is not None:
            is_active = status_filter.lower() == "active"
            query = query.where(User.is_active == is_active)

        # Count total
        result_all = await session.execute(query)
        all_users = result_all.scalars().all()
        total_items = len(all_users)

        # Pagination slice
        offset = (page - 1) * page_size
        items = all_users[offset : offset + page_size]

        # Build response users
        users_out = []
        for u in items:
            # Use role_name as role; detailed permissions/workflows can be derived per user if needed
            users_out.append(
                UserOut(
                    user_id=u.id,
                    email=u.email,
                    name=u.full_name,
                    role=u.role_name,
                    permissions=[],
                    workflows=[],
                    is_active=u.is_active,
                    created_at=u.createddate,
                    last_login=None,
                )
            )

        total_pages = (total_items + page_size - 1) // page_size if page_size else 1
        pagination = Pagination(
            page=page,
            page_size=page_size,
            total_items=total_items,
            total_pages=total_pages,
            has_next=page < total_pages,
            has_previous=page > 1,
        )

        return UserListResponse(users=users_out, pagination=pagination)


@router.get("/users/{user_id}", response_model=UserOut, summary="Get user by ID (admin only)")
async def get_user_by_id(
    user_id: UUID,
    current_user: dict = Depends(get_current_user_from_jwt),
):
    _require_admin(current_user)

    async with get_sync_database_url() as session:
        result = await session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Resource not found")

        return UserOut(
            user_id=user.id,
            email=user.email,
            name=user.full_name,
            role=user.role_name,
            permissions=[],
            workflows=[],
            is_active=user.is_active,
            created_at=user.createddate,
            last_login=None,
        )
