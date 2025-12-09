"""
Clinical Review Service
Business logic for clinical review workflow
"""

from typing import Optional, List, Dict, Any
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc, asc

from app.models.authorization import Authorization
from app.schemas.clinical import (
    ClinicalQueueResponse,
    ClinicalQueueItem,
    ClinicalCaseDetails,
    ClinicalCaseSubmission,
)
from app.schemas.base import PaginationInfo, Priority, Determination


class ClinicalReviewService:
    """Service for handling clinical review operations"""

    @staticmethod
    def get_clinical_queue(
        db: Session,
        page: int = 1,
        page_size: int = 10,
        status: Optional[str] = None,
        priority: Optional[Priority] = None,
        review_type: Optional[str] = None,
        template: Optional[str] = None,
        search: Optional[str] = None,
        sort_by: str = "received_date",
        sort_order: str = "desc",
    ) -> ClinicalQueueResponse:
        """
        Retrieve clinical review queue with filtering and pagination

        Args:
            db: Database session
            page: Page number
            page_size: Items per page
            status: Filter by status
            priority: Filter by priority
            review_type: Filter by review type
            template: Filter by template
            search: Search by auth number or member name
            sort_by: Sort field
            sort_order: Sort direction (asc/desc)

        Returns:
            ClinicalQueueResponse with cases and pagination info
        """
        query = db.query(Authorization).filter(Authorization.is_deleted == False)

        # Apply filters
        if status:
            query = query.filter(Authorization.status == status)

        if priority:
            query = query.filter(Authorization.priority == priority.value)

        if review_type:
            query = query.filter(
                Authorization.form_data["clinical_info"]["review_type"].astext
                == review_type
            )

        if template:
            query = query.filter(Authorization.template_type == template)

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
            cases.append(
                ClinicalQueueItem(
                    auth_number=case.authorization_number or "",
                    health_plan_id=case.healthplan_id,
                    member_name=case.member_name,
                    received_date=case.receipt_datetime,
                    start_of_service=case.start_of_care,
                    procedure_codes=case.procedure_code,
                    servicing_provider=case.servicing_name,
                    npi=case.requesting_npi,
                    status=case.status or "new",
                    priority=(
                        Priority(case.priority) if case.priority else Priority.STANDARD
                    ),
                    lapse_time=ClinicalReviewService._calculate_lapse_time(
                        case.receipt_datetime
                    ),
                    lapse_hours=ClinicalReviewService._calculate_lapse_hours(
                        case.receipt_datetime
                    ),
                    assigned_user=case.assigned_user,
                    result=case.result or "pending",
                    health_plan=case.health_plan,
                    template=case.template_type,
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

        return ClinicalQueueResponse(cases=cases, pagination=pagination)

    @staticmethod
    def get_clinical_case(
        db: Session, auth_number: str
    ) -> Optional[ClinicalCaseDetails]:
        """
        Retrieve detailed clinical case information

        Args:
            db: Database session
            auth_number: Authorization number

        Returns:
            ClinicalCaseDetails or None if not found
        """
        case = (
            db.query(Authorization)
            .filter(
                and_(
                    Authorization.authorization_number == auth_number,
                    Authorization.is_deleted == False,
                )
            )
            .first()
        )

        if not case:
            return None

        # Extract form data
        form_data = case.form_data or {}

        return ClinicalCaseDetails(
            auth_number=case.authorization_number or "",
            member_info=form_data.get("member_info"),
            contact_info=form_data.get("contact_info"),
            clinical_info=form_data.get("clinical_info"),
            ai_extractions=form_data.get("ai_extractions"),
            determination=case.determination,
            determination_type=form_data.get("determination_type"),
            status={
                "current_status": case.status,
                "assigned_user": case.assigned_user,
                "created_at": case.created_at.isoformat() if case.created_at else None,
                "updated_at": case.updated_at.isoformat() if case.updated_at else None,
            },
            documents=[],  # TODO: Fetch from documents table
        )

    @staticmethod
    def save_clinical_draft(
        db: Session,
        auth_number: str,
        submission: ClinicalCaseSubmission,
        user_email: str,
    ) -> Dict[str, Any]:
        """
        Save clinical case draft

        Args:
            db: Database session
            auth_number: Authorization number
            submission: Case submission data
            user_email: User email for audit

        Returns:
            Success response with saved timestamp
        """
        case = (
            db.query(Authorization)
            .filter(
                and_(
                    Authorization.authorization_number == auth_number,
                    Authorization.is_deleted == False,
                )
            )
            .first()
        )

        if not case:
            raise ValueError(f"Case {auth_number} not found")

        # Update form data
        form_data = case.form_data or {}
        if submission.member_info:
            form_data["member_info"] = submission.member_info.dict(exclude_none=True)
        if submission.contact_info:
            form_data["contact_info"] = submission.contact_info.dict(exclude_none=True)
        if submission.clinical_info:
            form_data["clinical_info"] = submission.clinical_info.dict(
                exclude_none=True
            )

        case.form_data = form_data
        case.status = "in_progress"
        case.updated_by = user_email
        case.updated_at = datetime.utcnow()

        db.commit()

        return {
            "message": "Draft saved successfully",
            "auth_number": auth_number,
            "saved_at": datetime.utcnow().isoformat(),
        }

    @staticmethod
    def submit_clinical_case(
        db: Session,
        auth_number: str,
        submission: ClinicalCaseSubmission,
        user_email: str,
    ) -> Dict[str, Any]:
        """
        Submit final clinical determination

        Args:
            db: Database session
            auth_number: Authorization number
            submission: Case submission data
            user_email: User email for audit

        Returns:
            Success response with submission details
        """
        case = (
            db.query(Authorization)
            .filter(
                and_(
                    Authorization.authorization_number == auth_number,
                    Authorization.is_deleted == False,
                )
            )
            .first()
        )

        if not case:
            raise ValueError(f"Case {auth_number} not found")

        # Validate required fields
        if not submission.determination:
            raise ValueError("Determination is required")

        # Update form data
        form_data = case.form_data or {}
        if submission.member_info:
            form_data["member_info"] = submission.member_info.dict(exclude_none=True)
        if submission.contact_info:
            form_data["contact_info"] = submission.contact_info.dict(exclude_none=True)
        if submission.clinical_info:
            form_data["clinical_info"] = submission.clinical_info.dict(
                exclude_none=True
            )

        case.form_data = form_data
        case.determination = submission.determination.value
        case.status = "completed"
        case.result = submission.determination.value
        case.updated_by = user_email
        case.updated_at = datetime.utcnow()
        case.review_date = datetime.utcnow()
        case.nurse_reviewer = user_email

        # If sent to MD, update escalation fields
        if submission.determination == Determination.SENT_TO_MD:
            case.escalation_date = datetime.utcnow()
            case.escalation_type = "nurse_review"
            case.original_reviewer = user_email

        db.commit()

        return {
            "message": "Case submitted successfully",
            "auth_number": auth_number,
            "determination": submission.determination.value,
            "submitted_at": datetime.utcnow().isoformat(),
        }

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

    @staticmethod
    def _calculate_lapse_hours(received_date: Optional[datetime]) -> int:
        """Calculate lapse time in hours"""
        if not received_date:
            return 0

        delta = datetime.utcnow() - received_date
        return int(delta.total_seconds() // 3600)
