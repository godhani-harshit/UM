"""
Appeals and Grievances API Endpoints
FastAPI router for appeals and grievances workflow
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.dependencies.auth import get_current_user
from app.services.appeals_grievances_service import AppealsGrievancesService
from app.schemas.appeals_grievances import (
    AppealsGrievancesQueueResponse,
    AppealsGrievancesCaseDetails,
    AppealsGrievancesCaseCreate,
    AppealsGrievancesCaseUpdate,
)
from app.schemas.base import Priority
from app.schemas.auth import UserProfile

router = APIRouter()


@router.get("/appeals-grievances/queue", response_model=AppealsGrievancesQueueResponse)
async def get_appeals_grievances_queue(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(10, ge=1, le=100, description="Items per page"),
    case_type: Optional[str] = Query(
        None, description="Filter by case type (appeal/grievance)"
    ),
    priority: Optional[Priority] = Query(None, description="Filter by priority"),
    status: Optional[str] = Query(None, description="Filter by status"),
    category: Optional[str] = Query(None, description="Filter by category"),
    requestor: Optional[str] = Query(None, description="Filter by requestor type"),
    received_date: Optional[str] = Query(None, description="Filter by received date"),
    search: Optional[str] = Query(None, description="Search by case ID or member name"),
    sort_by: str = Query("received_date", description="Sort field"),
    sort_order: str = Query("desc", description="Sort order (asc/desc)"),
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Retrieve appeals and grievances queue with filtering and pagination

    **Permissions**: Requires appeals_specialist or admin role
    """
    try:
        return AppealsGrievancesService.get_appeals_grievances_queue(
            db=db,
            page=page,
            page_size=page_size,
            case_type=case_type,
            priority=priority,
            status=status,
            category=category,
            requestor=requestor,
            received_date=received_date,
            search=search,
            sort_by=sort_by,
            sort_order=sort_order,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/appeals-grievances/cases", status_code=201)
async def create_appeals_grievances_case(
    case_data: AppealsGrievancesCaseCreate,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Create new appeals or grievances case

    **Permissions**: Requires appeals_specialist or admin role
    """
    try:
        return AppealsGrievancesService.create_appeals_grievances_case(
            db=db, case_data=case_data, user_email=current_user.email
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get(
    "/appeals-grievances/cases/{case_id}", response_model=AppealsGrievancesCaseDetails
)
async def get_appeals_grievances_case(
    case_id: str,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Retrieve detailed appeals/grievances case information

    **Permissions**: Requires appeals_specialist or admin role
    """
    case = AppealsGrievancesService.get_appeals_grievances_case(db, case_id)

    if not case:
        raise HTTPException(status_code=404, detail=f"Case {case_id} not found")

    return case


@router.patch(
    "/appeals-grievances/cases/{case_id}", response_model=AppealsGrievancesCaseDetails
)
async def update_appeals_grievances_case(
    case_id: str,
    update_data: AppealsGrievancesCaseUpdate,
    db: Session = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Update appeals/grievances case

    **Permissions**: Requires appeals_specialist or admin role
    """
    try:
        case = AppealsGrievancesService.update_appeals_grievances_case(
            db=db,
            case_id=case_id,
            update_data=update_data,
            user_email=current_user.email,
        )

        if not case:
            raise HTTPException(status_code=404, detail=f"Case {case_id} not found")

        return case
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
