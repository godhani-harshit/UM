"""
Medical Director workflow schemas
"""

from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime, date

from app.schemas.base import PaginationInfo
from app.schemas.common import MemberInfo, ContactInfo, ClinicalInfo, DocumentInfo


class MedicalDirectorQueueItem(BaseModel):
    """Medical director queue item"""

    auth_number: str
    member_name: Optional[str] = None
    dob: Optional[date] = None
    escalation_date: Optional[datetime] = None
    escalation_type: Optional[str] = None
    priority: Optional[str] = "standard"
    lapse_time: Optional[str] = None
    original_reviewer: Optional[str] = None
    template: Optional[str] = None
    complexity: Optional[str] = "standard"
    status: Optional[str] = "new"


class MedicalDirectorQueueResponse(BaseModel):
    """Medical director queue response with pagination"""

    cases: List[MedicalDirectorQueueItem]
    pagination: PaginationInfo


class NurseReviewSummary(BaseModel):
    """Nurse review summary information"""

    reviewer_name: Optional[str] = None
    review_date: Optional[datetime] = None
    initial_determination: Optional[str] = None
    clinical_rationale: Optional[str] = None
    escalation_reason: Optional[str] = None


class EscalationInfo(BaseModel):
    """Case escalation information"""

    escalation_type: Optional[str] = None
    escalation_date: Optional[datetime] = None
    escalated_by: Optional[str] = None
    reason: Optional[str] = None
    complexity: Optional[str] = "standard"


class MedicalDirectorCaseDetails(BaseModel):
    """Detailed medical director case information"""

    auth_number: str
    member_info: Optional[MemberInfo] = None
    contact_info: Optional[ContactInfo] = None
    clinical_info: Optional[ClinicalInfo] = None
    nurse_review: Optional[NurseReviewSummary] = None
    escalation_info: Optional[EscalationInfo] = None
    status: Optional[Dict[str, Any]] = None
    documents: Optional[List[DocumentInfo]] = None


class MedicalDirectorReviewSubmission(BaseModel):
    """Medical director review submission"""

    auth_number: str
    md_note: str
    md_determination: str  # approved, partially_approved, denied
    denial_rationale: Optional[str] = None
    additional_notes: Optional[str] = None
