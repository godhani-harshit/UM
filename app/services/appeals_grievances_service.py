"""
Appeals and Grievances Service
Business logic for appeals and grievances workflow
"""

from typing import Optional, Dict, Any
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc, asc
from uuid import uuid4

from app.models.authorization import Authorization
from app.schemas.appeals_grievances import (
    AppealsGrievancesQueueResponse,
    AppealsGrievancesQueueItem,
    AppealsGrievancesCaseDetails,
    AppealsGrievancesCaseCreate,
    AppealsGrievancesCaseUpdate,
)
from app.schemas.base import PaginationInfo, Priority


class AppealsGrievancesService:
    """Service for handling appeals and grievances operations"""

    @staticmethod
    def get_appeals_grievances_queue(
        db: Session,
        page: int = 1,
        page_size: int = 10,
        case_type: Optional[str] = None,
        priority: Optional[Priority] = None,
        status: Optional[str] = None,
        category: Optional[str] = None,
        requestor: Optional[str] = None,
        received_date: Optional[str] = None,
        search: Optional[str] = None,
        sort_by: str = "received_date",
        sort_order: str = "desc",
    ) -> AppealsGrievancesQueueResponse:
        """
        Retrieve appeals and grievances queue with filtering and pagination

        Args:
            db: Database session
            page: Page number
            page_size: Items per page
            case_type: Filter by case type (appeal/grievance)
            priority: Filter by priority
            status: Filter by status
            category: Filter by category
            requestor: Filter by requestor type
            received_date: Filter by received date
            search: Search by case ID or member name
            sort_by: Sort field
            sort_order: Sort direction

        Returns:
            AppealsGrievancesQueueResponse with cases and pagination
        """
        query = db.query(Authorization).filter(Authorization.is_deleted == False)

        # Apply filters
        if case_type:
            query = query.filter(
                Authorization.form_data["case_type"].astext == case_type
            )

        if priority:
            query = query.filter(Authorization.priority == priority.value)

        if status:
            query = query.filter(Authorization.status == status)

        if category:
            query = query.filter(
                Authorization.form_data["case_info"]["category"].astext == category
            )

        if requestor:
            query = query.filter(
                Authorization.form_data["case_info"]["requestor"].astext == requestor
            )

        if received_date:
            query = query.filter(
                Authorization.receipt_datetime >= datetime.fromisoformat(received_date)
            )

        if search:
            search_filter = or_(
                Authorization.authorization_number.ilike(f"%{search}%"),
                Authorization.member_name.ilike(f"%{search}%"),
            )
            query = query.filter(search_filter)

        # Apply sorting
        sort_column = getattr(Authorization, sort_by, Authorization.receipt_datetime)
        if sort_order == "desc":
            query = query.order_by(desc(sort_column))
        else:
            query = query.order_by(asc(sort_column))

        # Get total count
        total_items = query.count()

        # Apply pagination
        offset = (page - 1) * page_size
        cases_db = query.offset(offset).limit(page_size).all()

        # Convert to response models
        cases = []
        for case in cases_db:
            form_data = case.form_data or {}
            case_info = form_data.get("case_info", {})

            cases.append(
                AppealsGrievancesQueueItem(
                    case_id=case.authorization_number or str(uuid4()),
                    member_name=case.member_name,
                    dob=case.dob,
                    received_date=case.receipt_datetime,
                    case_type=form_data.get("case_type", "appeal"),
                    category=case_info.get("category"),
                    priority=(
                        Priority(case.priority) if case.priority else Priority.STANDARD
                    ),
                    lapse_time=AppealsGrievancesService._calculate_lapse_time(
                        case.receipt_datetime
                    ),
                    requestor=case_info.get("requestor"),
                    status=case.status or "received",
                    assigned_to=case.assigned_user,
                )
            )

        # Calculate pagination info
        total_pages = (total_items + page_size - 1) // page_size
        pagination = PaginationInfo(
            page=page,
            page_size=page_size,
            total_items=total_items,
            total_pages=total_pages,
            has_next=page < total_pages,
            has_previous=page > 1,
        )

        return AppealsGrievancesQueueResponse(cases=cases, pagination=pagination)

    @staticmethod
    def create_appeals_grievances_case(
        db: Session, case_data: AppealsGrievancesCaseCreate, user_email: str
    ) -> Dict[str, Any]:
        """
        Create new appeals or grievances case

        Args:
            db: Database session
            case_data: Case creation data
            user_email: User email for audit

        Returns:
            Success response with case ID
        """
        # Generate case ID
        case_id = f"AG-{datetime.utcnow().year}-{str(uuid4())[:8].upper()}"

        # Create authorization record
        new_case = Authorization(
            authorization_number=case_id,
            member_name=case_data.member_name,
            dob=(
                datetime.strptime(case_data.dob, "%m/%d/%Y").date()
                if "/" in case_data.dob
                else datetime.fromisoformat(case_data.dob).date()
            ),
            healthplan_id=case_data.healthplan_id,
            health_plan=case_data.health_plan,
            priority=case_data.request_details.priority.value,
            receipt_datetime=case_data.request_details.receipt_datetime,
            status="received",
            form_data={
                "case_type": case_data.case_type,
                "requestor": (
                    case_data.requestor.dict(exclude_none=True)
                    if case_data.requestor
                    else None
                ),
                "request_details": case_data.request_details.dict(exclude_none=True),
                "processing": (
                    case_data.processing.dict(exclude_none=True)
                    if case_data.processing
                    else None
                ),
            },
            created_by=user_email,
            created_at=datetime.utcnow(),
            updated_by=user_email,
            updated_at=datetime.utcnow(),
            is_deleted=False,
            version=1,
        )

        db.add(new_case)
        db.commit()
        db.refresh(new_case)

        return {
            "case_id": case_id,
            "message": "Appeals/Grievances case created successfully",
        }

    @staticmethod
    def get_appeals_grievances_case(
        db: Session, case_id: str
    ) -> Optional[AppealsGrievancesCaseDetails]:
        """
        Retrieve detailed appeals/grievances case information

        Args:
            db: Database session
            case_id: Case ID

        Returns:
            AppealsGrievancesCaseDetails or None if not found
        """
        case = (
            db.query(Authorization)
            .filter(
                and_(
                    Authorization.authorization_number == case_id,
                    Authorization.is_deleted == False,
                )
            )
            .first()
        )

        if not case:
            return None

        # Extract form data
        form_data = case.form_data or {}

        return AppealsGrievancesCaseDetails(
            case_id=case.authorization_number or "",
            member_info=form_data.get("member_info"),
            case_info=form_data.get("case_info"),
            contact_info=form_data.get("contact_info"),
            review_details=form_data.get("review_details"),
            status={
                "current_status": case.status,
                "assigned_user": case.assigned_user,
                "created_at": case.created_at.isoformat() if case.created_at else None,
                "updated_at": case.updated_at.isoformat() if case.updated_at else None,
            },
            documents=[],  # TODO: Fetch from documents table
        )

    @staticmethod
    def update_appeals_grievances_case(
        db: Session,
        case_id: str,
        update_data: AppealsGrievancesCaseUpdate,
        user_email: str,
    ) -> Optional[AppealsGrievancesCaseDetails]:
        """
        Update appeals/grievances case

        Args:
            db: Database session
            case_id: Case ID
            update_data: Update data
            user_email: User email for audit

        Returns:
            Updated AppealsGrievancesCaseDetails or None if not found
        """
        case = (
            db.query(Authorization)
            .filter(
                and_(
                    Authorization.authorization_number == case_id,
                    Authorization.is_deleted == False,
                )
            )
            .first()
        )

        if not case:
            return None

        # Update fields
        if update_data.status:
            case.status = update_data.status

        if update_data.assigned_to:
            case.assigned_user = update_data.assigned_to

        if update_data.notes:
            form_data = case.form_data or {}
            if "notes" not in form_data:
                form_data["notes"] = []
            form_data["notes"].append(
                {
                    "note": update_data.notes,
                    "added_by": user_email,
                    "added_at": datetime.utcnow().isoformat(),
                }
            )
            case.form_data = form_data

        case.updated_by = user_email
        case.updated_at = datetime.utcnow()
        case.version += 1

        db.commit()
        db.refresh(case)

        # Return updated case details
        return AppealsGrievancesService.get_appeals_grievances_case(db, case_id)

    @staticmethod
    def _calculate_lapse_time(received_date: Optional[datetime]) -> str:
        """Calculate human-readable lapse time"""
        if not received_date:
            return "N/A"

        delta = datetime.utcnow() - received_date
        days = delta.days
        hours = delta.seconds // 3600

        if days > 0:
            return f"{days} days {hours} hours"
        else:
            return f"{hours} hours"
