"""
Clinical Review workflow schemas
"""

from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime, date

from app.schemas.base import PaginationInfo
from app.schemas.common import MemberInfo, ContactInfo, ClinicalInfo, DocumentInfo


class ClinicalQueueItem(BaseModel):
    """Clinical review queue item"""

    auth_number: str
    health_plan_id: Optional[str] = None
    member_name: Optional[str] = None
    received_date: Optional[datetime] = None
    start_of_service: Optional[date] = None
    procedure_codes: Optional[str] = None
    servicing_provider: Optional[str] = None
    npi: Optional[str] = None
    status: Optional[str] = "new"
    priority: Optional[str] = "standard"
    lapse_time: Optional[str] = None
    lapse_hours: Optional[int] = None
    assigned_user: Optional[str] = None
    result: Optional[str] = "pending"
    health_plan: Optional[str] = None
    template: Optional[str] = None


class ClinicalQueueResponse(BaseModel):
    """Clinical review queue response with pagination"""

    cases: List[ClinicalQueueItem]
    pagination: PaginationInfo


class ClinicalCaseDetails(BaseModel):
    """Detailed clinical case information"""

    auth_number: str
    member_info: Optional[MemberInfo] = None
    contact_info: Optional[ContactInfo] = None
    clinical_info: Optional[ClinicalInfo] = None
    ai_extractions: Optional[Dict[str, Any]] = None
    determination: Optional[str] = None
    determination_type: Optional[str] = None
    status: Optional[Dict[str, Any]] = None
    documents: Optional[List[DocumentInfo]] = None


class ClinicalCaseSubmission(BaseModel):
    """Clinical case submission/update"""

    auth_number: str
    determination: str  # approved, denied, partially_approved, sent_to_md
    member_info: Optional[MemberInfo] = None
    contact_info: Optional[ContactInfo] = None
    clinical_info: Optional[ClinicalInfo] = None
    determination_type: Optional[str] = None
    documents: Optional[List[Dict[str, Any]]] = None
