"""
Medical Director API Endpoints
FastAPI router for medical director review workflow
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.dependencies.auth import get_current_user
from app.services.medical_director_service import MedicalDirectorService
from app.schemas.medical_director import (
    MedicalDirectorQueueResponse,
    MedicalDirectorCaseDetails,
    MedicalDirectorReviewSubmission,
)
from app.schemas.base import Priority
from app.schemas.auth import UserProfile

router = APIRouter()


@router.get("/medical-director/queue", response_model=MedicalDirectorQueueResponse)
async def get_medical_director_queue(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(10, ge=1, le=100, description="Items per page"),
    escalation_type: Optional[str] = Query(
        None, description="Filter by escalation type"
    ),
    priority: Optional[Priority] = Query(None, description="Filter by priority"),
    complexity: Optional[str] = Query(None, description="Filter by complexity"),
    original_reviewer: Optional[str] = Query(
        None, description="Filter by original reviewer"
    ),
    template: Optional[str] = Query(None, description="Filter by template"),
    search: Optional[str] = Query(
        None, description="Search by auth number or member name"
    ),
    sort_by: str = Query("escalation_date", description="Sort field"),
    sort_order: str = Query("desc", description="Sort order (asc/desc)"),
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Retrieve medical director queue with filtering and pagination

    **Permissions**: Requires medical_director role
    """
    try:
        return MedicalDirectorService.get_medical_director_queue(
            db=db,
            page=page,
            page_size=page_size,
            escalation_type=escalation_type,
            priority=priority,
            complexity=complexity,
            original_reviewer=original_reviewer,
            template=template,
            search=search,
            sort_by=sort_by,
            sort_order=sort_order,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get(
    "/medical-director/cases/{auth_number}", response_model=MedicalDirectorCaseDetails
)
async def get_medical_director_case(
    auth_number: str,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Retrieve detailed medical director case information

    **Permissions**: Requires medical_director role
    """
    case = MedicalDirectorService.get_medical_director_case(db, auth_number)

    if not case:
        raise HTTPException(status_code=404, detail=f"Case {auth_number} not found")

    return case


@router.post("/medical-director/cases/{auth_number}/draft")
async def save_medical_director_draft(
    auth_number: str,
    submission: MedicalDirectorReviewSubmission,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Save medical director review draft

    **Permissions**: Requires medical_director role
    """
    try:
        return MedicalDirectorService.save_medical_director_draft(
            db=db,
            auth_number=auth_number,
            submission=submission,
            user_email=current_user.email,
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/medical-director/cases/{auth_number}/submit")
async def submit_medical_director_case(
    auth_number: str,
    submission: MedicalDirectorReviewSubmission,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Submit final medical director determination

    **Permissions**: Requires medical_director role
    """
    try:
        return MedicalDirectorService.submit_medical_director_case(
            db=db,
            auth_number=auth_number,
            submission=submission,
            user_email=current_user.email,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
