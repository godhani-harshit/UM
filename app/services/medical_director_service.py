"""
Medical Director Service
Business logic for medical director review workflow
"""

from typing import Optional, Dict, Any
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc, asc

from app.models.authorization import Authorization
from app.schemas.medical_director import (
    MedicalDirectorQueueResponse,
    MedicalDirectorQueueItem,
    MedicalDirectorCaseDetails,
    MedicalDirectorReviewSubmission,
    NurseReviewSummary,
    EscalationInfo,
)
from app.schemas.base import PaginationInfo, Priority


class MedicalDirectorService:
    """Service for handling medical director review operations"""

    @staticmethod
    def get_medical_director_queue(
        db: Session,
        page: int = 1,
        page_size: int = 10,
        escalation_type: Optional[str] = None,
        priority: Optional[Priority] = None,
        complexity: Optional[str] = None,
        original_reviewer: Optional[str] = None,
        template: Optional[str] = None,
        search: Optional[str] = None,
        sort_by: str = "escalation_date",
        sort_order: str = "desc",
    ) -> MedicalDirectorQueueResponse:
        """
        Retrieve medical director queue with filtering and pagination

        Args:
            db: Database session
            page: Page number
            page_size: Items per page
            escalation_type: Filter by escalation type
            priority: Filter by priority
            complexity: Filter by complexity
            original_reviewer: Filter by original reviewer
            template: Filter by template
            search: Search by auth number or member name
            sort_by: Sort field
            sort_order: Sort direction

        Returns:
            MedicalDirectorQueueResponse with cases and pagination
        """
        query = db.query(Authorization).filter(
            and_(
                Authorization.is_deleted == False,
                Authorization.escalation_date.isnot(None),
            )
        )

        # Apply filters
        if escalation_type:
            query = query.filter(Authorization.escalation_type == escalation_type)

        if priority:
            query = query.filter(Authorization.priority == priority.value)

        if complexity:
            query = query.filter(Authorization.complexity == complexity)

        if original_reviewer:
            query = query.filter(
                Authorization.original_reviewer.ilike(f"%{original_reviewer}%")
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
        sort_column = getattr(Authorization, sort_by, Authorization.escalation_date)
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
                MedicalDirectorQueueItem(
                    auth_number=case.authorization_number or "",
                    member_name=case.member_name,
                    dob=case.dob,
                    escalation_date=case.escalation_date,
                    escalation_type=case.escalation_type,
                    priority=(
                        Priority(case.priority) if case.priority else Priority.STANDARD
                    ),
                    lapse_time=MedicalDirectorService._calculate_lapse_time(
                        case.escalation_date
                    ),
                    original_reviewer=case.original_reviewer,
                    template=case.template_type,
                    complexity=case.complexity or "standard",
                    status=case.status or "new",
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

        return MedicalDirectorQueueResponse(cases=cases, pagination=pagination)

    @staticmethod
    def get_medical_director_case(
        db: Session, auth_number: str
    ) -> Optional[MedicalDirectorCaseDetails]:
        """
        Retrieve detailed medical director case information

        Args:
            db: Database session
            auth_number: Authorization number

        Returns:
            MedicalDirectorCaseDetails or None if not found
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

        # Build nurse review summary
        nurse_review = None
        if case.nurse_reviewer:
            nurse_review = NurseReviewSummary(
                reviewer_name=case.nurse_reviewer,
                review_date=case.review_date,
                initial_determination=case.determination,
                clinical_rationale=form_data.get("clinical_rationale"),
                escalation_reason=form_data.get("escalation_reason"),
            )

        # Build escalation info
        escalation_info = None
        if case.escalation_date:
            escalation_info = EscalationInfo(
                escalation_type=case.escalation_type,
                escalation_date=case.escalation_date,
                escalated_by=case.original_reviewer,
                reason=form_data.get("escalation_reason"),
                complexity=case.complexity or "standard",
            )

        return MedicalDirectorCaseDetails(
            auth_number=case.authorization_number or "",
            member_info=form_data.get("member_info"),
            contact_info=form_data.get("contact_info"),
            clinical_info=form_data.get("clinical_info"),
            nurse_review=nurse_review,
            escalation_info=escalation_info,
            status={
                "current_status": case.status,
                "assigned_user": case.assigned_user,
                "created_at": case.created_at.isoformat() if case.created_at else None,
                "updated_at": case.updated_at.isoformat() if case.updated_at else None,
            },
            documents=[],  # TODO: Fetch from documents table
        )

    @staticmethod
    def save_medical_director_draft(
        db: Session,
        auth_number: str,
        submission: MedicalDirectorReviewSubmission,
        user_email: str,
    ) -> Dict[str, Any]:
        """
        Save medical director review draft

        Args:
            db: Database session
            auth_number: Authorization number
            submission: Review submission data
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

        # Update form data with MD notes
        form_data = case.form_data or {}
        form_data["md_note"] = submission.md_note
        form_data["md_determination"] = submission.md_determination.value
        if submission.denial_rationale:
            form_data["denial_rationale"] = submission.denial_rationale
        if submission.additional_notes:
            form_data["additional_notes"] = submission.additional_notes

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
    def submit_medical_director_case(
        db: Session,
        auth_number: str,
        submission: MedicalDirectorReviewSubmission,
        user_email: str,
    ) -> Dict[str, Any]:
        """
        Submit final medical director determination

        Args:
            db: Database session
            auth_number: Authorization number
            submission: Review submission data
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
        if not submission.md_note or not submission.md_determination:
            raise ValueError("MD note and determination are required")

        # Update form data with MD notes
        form_data = case.form_data or {}
        form_data["md_note"] = submission.md_note
        form_data["md_determination"] = submission.md_determination.value
        if submission.denial_rationale:
            form_data["denial_rationale"] = submission.denial_rationale
        if submission.additional_notes:
            form_data["additional_notes"] = submission.additional_notes

        case.form_data = form_data
        case.md_determination = submission.md_determination.value
        case.determination = submission.md_determination.value
        case.status = "completed"
        case.result = submission.md_determination.value
        case.updated_by = user_email
        case.updated_at = datetime.utcnow()

        db.commit()

        return {
            "message": "Medical director determination submitted successfully",
            "auth_number": auth_number,
            "determination": submission.md_determination.value,
            "submitted_at": datetime.utcnow().isoformat(),
        }

    @staticmethod
    def _calculate_lapse_time(escalation_date: Optional[datetime]) -> str:
        """Calculate human-readable lapse time since escalation"""
        if not escalation_date:
            return "N/A"

        delta = datetime.utcnow() - escalation_date
        days = delta.days
        hours = delta.seconds // 3600

        if days > 0:
            return f"{days} days {hours} hours"
        else:
            return f"{hours} hours"
