from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime, date, time

class IntakeCaseCreate(BaseModel):
    file_name: str
    file_url: str
    file_size: int
    file_arrival_time: Optional[datetime] = None
    source: str = "Upload"


class IntakeCaseResponse(BaseModel):
    authorization_id: int
    document_id: str
    file_name: str
    file_url: str
    file_size: int
    file_arrival_time: datetime
    status: str
    source: str
    message: str

class IntakeQueueItem(BaseModel):
    source: Optional[str] = None
    health_plan: Optional[str] = None
    document_id: Optional[str] = None
    auth_number: Optional[str] = None
    template: Optional[str] = None
    member_name: Optional[str] = None
    dob: Optional[datetime] = None
    queue_time: Optional[datetime] = None
    received_date: Optional[datetime] = None
    priority: Optional[str] = None
    lapse_time: Optional[str] = None
    lapse_hour: Optional[time] = None
    status: Optional[str] = None
    assigned_to: Optional[str] = None


class Pagination(BaseModel):
    page: int
    page_size: int
    total_pages: int
    has_next: bool
    has_previous: bool


class Statistics(BaseModel):
    total_cases: int
    available_cases: int
    expedited_cases: int


class IntakeQueueResponse(BaseModel):
    cases: List[IntakeQueueItem]
    pagination: Pagination
    statistics: Statistics


class IntakeCaseDetailResponse(BaseModel):
    id: int
    document_id: str
    file_name: str
    file_url: str
    file_size: int
    file_arrival_time: datetime
    authorization_number: Optional[str] = None
    patient_id: Optional[str] = None
    member_name: str
    dob: date
    healthplan_id: str
    health_plan: str
    requesting_npi: str
    requesting_name: str
    servicing_name: Optional[str] = None
    source: str
    template_type: str
    priority: str
    receipt_datetime: datetime
    start_of_care: Optional[date] = None
    status: str
    result: Optional[str] = None
    assigned_user: Optional[str] = None
    procedure_code: Optional[str] = None
    determination: Optional[str] = None
    md_determination: Optional[str] = None
    escalation_date: Optional[datetime] = None
    escalation_type: Optional[str] = None
    nurse_reviewer: Optional[str] = None
    original_reviewer: Optional[str] = None
    review_date: Optional[datetime] = None
    complexity: Optional[str] = None
    form_data: dict
    created_at: datetime
    created_by: Optional[str] = None
    updated_at: datetime
    updated_by: Optional[str] = None
    is_deleted: bool
    deleted_at: Optional[datetime] = None
    deleted_by: Optional[str] = None
    version: int