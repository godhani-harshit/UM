from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.services.case_lock_service import acquire_lock, release_lock, get_lock_status
from app.services.auth_service import get_current_user_from_jwt
from app.core.logging import logger

router = APIRouter()

@router.post("/case-lock/{document_id}/acquire")
async def acquire_document_lock(
    document_id: str,
    force: bool = Query(False, description="Force acquire lock (admin only)"),
    session: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user_from_jwt)
):
    try:
        user_email = current_user.get('email')
        is_admin = current_user.get('role') == 'admin'  # Adjust based on your role logic
        
        # Only allow force if user is admin
        if force and not is_admin:
            raise HTTPException(
                status_code=403,
                detail="Only administrators can force acquire locks"
            )
        
        result = await acquire_lock(
            session=session,
            document_id=document_id,
            user_email=user_email,
            is_admin=is_admin,
            force=force
        )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Failed to acquire lock: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to acquire lock: {str(e)}"
        )

@router.post("/case-lock/{document_id}/release")
async def release_document_lock(
    document_id: str,
    session: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user_from_jwt)
):
    try:
        user_email = current_user.get('email')
        is_admin = current_user.get('role') == 'admin'
        
        success = await release_lock(
            session=session,
            document_id=document_id,
            user_email=user_email,
            force=is_admin  # Admins can force release any lock
        )
        
        if success:
            return {"success": True, "message": "Lock released successfully"}
        else:
            raise HTTPException(
                status_code=403,
                detail="Unable to release lock. You may not own this lock."
            )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Failed to release lock: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to release lock: {str(e)}"
        )

@router.get("/case-lock/{document_id}/status")
async def get_document_lock_status(
    document_id: str,
    session: AsyncSession = Depends(get_db)
):
    try:
        status = await get_lock_status(session, document_id)
        return status
        
    except Exception as e:
        logger.error(f"❌ Failed to get lock status: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get lock status: {str(e)}"
        )