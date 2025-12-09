"""
Clinical Review API Endpoints
FastAPI router for clinical review workflow
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.dependencies.auth import get_current_user
from app.services.clinical_service import ClinicalReviewService
from app.schemas.clinical import (
    ClinicalQueueResponse,
    ClinicalCaseDetails,
    ClinicalCaseSubmission,
)
from app.schemas.base import Priority
from app.schemas.auth import UserProfile

router = APIRouter()


@router.get("/clinical/queue", response_model=ClinicalQueueResponse)
async def get_clinical_queue(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(10, ge=1, le=100, description="Items per page"),
    status: Optional[str] = Query(None, description="Filter by status"),
    priority: Optional[Priority] = Query(None, description="Filter by priority"),
    review_type: Optional[str] = Query(None, description="Filter by review type"),
    template: Optional[str] = Query(None, description="Filter by template"),
    search: Optional[str] = Query(
        None, description="Search by auth number or member name"
    ),
    sort_by: str = Query("received_date", description="Sort field"),
    sort_order: str = Query("desc", description="Sort order (asc/desc)"),
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Retrieve clinical review queue with filtering and pagination

    **Permissions**: Requires nurse_reviewer or medical_director role
    """
    try:
        return ClinicalReviewService.get_clinical_queue(
            db=db,
            page=page,
            page_size=page_size,
            status=status,
            priority=priority,
            review_type=review_type,
            template=template,
            search=search,
            sort_by=sort_by,
            sort_order=sort_order,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/clinical/cases/{auth_number}", response_model=ClinicalCaseDetails)
async def get_clinical_case(
    auth_number: str,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Retrieve detailed clinical case information

    **Permissions**: Requires nurse_reviewer or medical_director role
    """
    case = ClinicalReviewService.get_clinical_case(db, auth_number)

    if not case:
        raise HTTPException(status_code=404, detail=f"Case {auth_number} not found")

    return case


@router.post("/clinical/cases/{auth_number}/draft")
async def save_clinical_draft(
    auth_number: str,
    submission: ClinicalCaseSubmission,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Save clinical case draft

    **Permissions**: Requires nurse_reviewer role
    """
    try:
        return ClinicalReviewService.save_clinical_draft(
            db=db,
            auth_number=auth_number,
            submission=submission,
            user_email=current_user.email,
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/clinical/cases/{auth_number}/submit")
async def submit_clinical_case(
    auth_number: str,
    submission: ClinicalCaseSubmission,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Submit final clinical determination

    **Permissions**: Requires nurse_reviewer role
    """
    try:
        return ClinicalReviewService.submit_clinical_case(
            db=db,
            auth_number=auth_number,
            submission=submission,
            user_email=current_user.email,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
