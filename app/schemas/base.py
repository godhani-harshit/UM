"""
Base schemas and enums used across the application
"""

from pydantic import BaseModel
from enum import Enum


# ============================================================================
# ENUMS
# ============================================================================


class UserRole(str, Enum):
    """User roles in the system"""

    INTAKE_SPECIALIST = "intake_specialist"
    NURSE_REVIEWER = "nurse_reviewer"
    MEDICAL_DIRECTOR = "medical_director"
    APPEALS_SPECIALIST = "appeals_specialist"
    ADMIN = "admin"


class WorkflowType(str, Enum):
    """Available workflow types"""

    INTAKE = "intake"
    CLINICAL_REVIEW = "clinical_review"
    MEDICAL_DIRECTOR = "medical_director"
    APPEALS_GRIEVANCES = "appeals_grievances"


class Priority(str, Enum):
    """Case priority levels"""

    URGENT = "urgent"
    EXPEDITED = "expedited"
    STANDARD = "standard"


class ReviewType(str, Enum):
    """Clinical review types"""

    PRE_SERVICE = "pre_service"
    CONCURRENT = "concurrent"
    RETROSPECTIVE = "retrospective"


class Determination(str, Enum):
    """Case determination outcomes"""

    APPROVED = "approved"
    DENIED = "denied"
    PARTIALLY_APPROVED = "partially_approved"
    SENT_TO_MD = "sent_to_md"


class CaseStatus(str, Enum):
    """Case status values"""

    NEW = "new"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    UNABLE_TO_PROCESS = "unable_to_process"


class FrequencyType(str, Enum):
    """Medication frequency types"""

    DAYS = "days"
    WEEKS = "weeks"
    MONTHS = "months"


# ============================================================================
# BASE SCHEMAS
# ============================================================================


class PaginationInfo(BaseModel):
    """Pagination information for list responses"""

    page: int = 1
    page_size: int = 10
    total_items: int
    total_pages: int
    has_next: bool
    has_previous: bool


class ErrorResponse(BaseModel):
    """Standard error response"""

    error: str
    message: str
    details: dict = None
    timestamp: str


class ValidationErrorDetail(BaseModel):
    """Validation error detail"""

    field: str
    message: str


class ValidationErrorResponse(BaseModel):
    """Validation error response"""

    error: str = "validation_error"
    message: str = "Validation failed"
    errors: list[ValidationErrorDetail]
    timestamp: str
