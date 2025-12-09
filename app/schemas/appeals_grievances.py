"""
Appeals and Grievances workflow schemas
"""

from pydantic import BaseModel, EmailStr
from typing import Optional, List, Dict, Any
from datetime import datetime, date

from app.schemas.base import PaginationInfo
from app.schemas.common import MemberInfo, ContactInfo, DocumentInfo


class AppealsGrievancesQueueItem(BaseModel):
    """Appeals and grievances queue item"""

    case_id: str
    member_name: Optional[str] = None
    dob: Optional[date] = None
    received_date: Optional[datetime] = None
    case_type: str  # appeal or grievance
    category: Optional[str] = None
    priority: Optional[str] = "standard"
    lapse_time: Optional[str] = None
    requestor: Optional[str] = None
    status: Optional[str] = "received"
    assigned_to: Optional[str] = None


class AppealsGrievancesQueueResponse(BaseModel):
    """Appeals and grievances queue response with pagination"""

    cases: List[AppealsGrievancesQueueItem]
    pagination: PaginationInfo


class RequestorInfo(BaseModel):
    """Requestor information"""

    relationship: Optional[str] = None
    npi: Optional[str] = None
    name: Optional[str] = None
    street_address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    phone: Optional[str] = None
    fax: Optional[str] = None
    email: Optional[EmailStr] = None


class AppealsGrievancesRequestDetails(BaseModel):
    """Request details for appeals/grievances"""

    receipt_datetime: datetime
    priority: str
    case_category: str
    date_of_service: Optional[date] = None
    claim_number: Optional[str] = None
    authorization_number: Optional[str] = None
    waiver_of_liability: Optional[str] = None


class AppealsGrievancesProcessing(BaseModel):
    """Processing information"""

    processing_result: Optional[str] = None
    unable_to_process_reason: Optional[str] = None
    sent_to_um: Optional[bool] = None


class AppealsGrievancesCaseCreate(BaseModel):
    """Create new appeals/grievances case"""

    member_name: str
    dob: str
    healthplan_id: str
    health_plan: str
    case_type: str  # appeal or grievance
    requestor: Optional[RequestorInfo] = None
    request_details: AppealsGrievancesRequestDetails
    processing: Optional[AppealsGrievancesProcessing] = None


class AppealsGrievancesCaseInfo(BaseModel):
    """Case information"""

    case_type: str
    category: Optional[str] = None
    priority: Optional[str] = "standard"
    requestor: Optional[str] = None
    description: Optional[str] = None
    received_date: Optional[datetime] = None
    due_date: Optional[datetime] = None
    original_determination: Optional[str] = None
    original_determination_date: Optional[datetime] = None


class MemberNotification(BaseModel):
    """Member notification information"""

    notification_sent: bool = False
    notification_date: Optional[datetime] = None
    notification_method: Optional[str] = None


class AppealsGrievancesReviewDetails(BaseModel):
    """Review details"""

    reviewer_name: Optional[str] = None
    review_date: Optional[datetime] = None
    investigation_summary: Optional[str] = None
    resolution: Optional[str] = None
    resolution_rationale: Optional[str] = None
    corrective_actions: Optional[str] = None
    member_notification: Optional[MemberNotification] = None


class AppealsGrievancesCaseDetails(BaseModel):
    """Detailed appeals/grievances case information"""

    case_id: str
    member_info: Optional[MemberInfo] = None
    case_info: Optional[AppealsGrievancesCaseInfo] = None
    contact_info: Optional[ContactInfo] = None
    review_details: Optional[AppealsGrievancesReviewDetails] = None
    status: Optional[Dict[str, Any]] = None
    documents: Optional[List[DocumentInfo]] = None


class AppealsGrievancesCaseUpdate(BaseModel):
    """Update appeals/grievances case"""

    status: Optional[str] = None
    notes: Optional[str] = None
    assigned_to: Optional[str] = None
