"""
Comprehensive Pydantic schemas for Intake Processing Workflow APIs.

This module contains all request/response models for the intake system,
including nested objects, enums, and validation rules.
"""

from pydantic import BaseModel, Field, validator, EmailStr
from typing import Optional, List, Dict, Any
from datetime import datetime, date
from enum import Enum
import re


# ============================================================================
# ENUMS
# ============================================================================

class CaseStatus(str, Enum):
    """Case processing status"""
    NEW = "new"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    UNABLE_TO_PROCESS = "unable_to_process"


class Priority(str, Enum):
    """Case priority level"""
    STANDARD = "standard"
    EXPEDITED = "expedited"
    URGENT = "urgent"


class ProcessingResult(str, Enum):
    """Processing outcome"""
    PROCESSED = "processed"
    UNABLE_TO_PROCESS = "unable_to_process"
    PENDING = "pending"


class TemplateType(str, Enum):
    """Document template types"""
    IP_HOSPITAL = "IP Hospital (REV 0110)"
    OP_SURGERY = "OP Surgery"
    HOME_HEALTH = "Home Health"
    DME = "DME"
    PHARMACY = "Pharmacy"
    UNDETERMINED = "Undetermined"


class DocumentSource(str, Enum):
    """Document source types"""
    FAX = "Fax"
    UPLOAD = "Upload"
    EMAIL = "Email"
    PORTAL = "Portal"


# ============================================================================
# NESTED OBJECT SCHEMAS
# ============================================================================

class MemberInfo(BaseModel):
    """Member/Patient information"""
    member_name: str = Field(..., min_length=1, max_length=200, description="Full name of the member")
    dob: date = Field(..., description="Date of birth")
    health_plan_id: str = Field(..., min_length=1, max_length=100, description="Health plan member ID")
    health_plan: str = Field(..., min_length=1, max_length=200, description="Health plan name")
    authorization_number: Optional[str] = Field(None, max_length=100, description="Authorization number if available")

    @validator('member_name')
    def validate_member_name(cls, v):
        if not v or v.strip() == "":
            raise ValueError("Member name cannot be empty")
        return v.strip()

    class Config:
        json_schema_extra = {
            "example": {
                "member_name": "John Doe",
                "dob": "1980-01-15",
                "health_plan_id": "HP123456",
                "health_plan": "Blue Cross",
                "authorization_number": "AUTH-2024-1234"
            }
        }


class RequestProviderInfo(BaseModel):
    """Requesting provider information"""
    requesting_provider: str = Field("", max_length=200, description="Requesting provider name")
    requesting_provider_npi: str = Field("", max_length=10, description="10-digit NPI number")
    requesting_phone: str = Field("", max_length=20, description="Phone number")
    requesting_fax: str = Field("", max_length=20, description="Fax number")
    requesting_email: EmailStr = Field("", description="Email address")

    @validator('requesting_provider_npi')
    def validate_npi(cls, v):
        if v and not re.match(r'^\d{10}$', v):
            raise ValueError("NPI must be exactly 10 digits")
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "requesting_provider": "Dr. Jane Smith",
                "requesting_provider_npi": "1234567890",
                "requesting_phone": "(555) 123-4567",
                "requesting_fax": "(555) 123-4568",
                "requesting_email": "dr.smith@example.com"
            }
        }


class ServiceProviderInfo(BaseModel):
    """Servicing provider information"""
    servicing_provider: str = Field("", max_length=200, description="Servicing provider name")
    servicing_provider_npi: str = Field("", max_length=10, description="10-digit NPI number")
    servicing_phone: str = Field("", max_length=20, description="Phone number")
    servicing_fax: str = Field("", max_length=20, description="Fax number")
    servicing_email: EmailStr = Field("", description="Email address")

    @validator('servicing_provider_npi')
    def validate_npi(cls, v):
        if v and not re.match(r'^\d{10}$', v):
            raise ValueError("NPI must be exactly 10 digits")
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "servicing_provider": "City Hospital",
                "servicing_provider_npi": "9876543210",
                "servicing_phone": "(555) 987-6543",
                "servicing_fax": "(555) 987-6544",
                "servicing_email": "admin@cityhospital.com"
            }
        }


class RequestInfo(BaseModel):
    """Request metadata information"""
    template_type: str = Field(..., description="Template type used for the request")
    received_datetime: datetime = Field(..., description="Date and time request was received")
    start_of_service: Optional[datetime] = Field(None, description="Requested start date of service")
    priority: Priority = Field(Priority.STANDARD, description="Request priority level")

    class Config:
        json_schema_extra = {
            "example": {
                "template_type": "IP Hospital (REV 0110)",
                "received_datetime": "2025-10-22T08:47:21.885Z",
                "start_of_service": "2025-10-25T00:00:00.000Z",
                "priority": "expedited"
            }
        }


class RequestedItem(BaseModel):
    """Individual requested service or item"""
    procedure_code: str = Field(..., max_length=20, description="CPT/HCPCS procedure code")
    description: str = Field(..., max_length=500, description="Service description")
    quantity: Optional[int] = Field(None, ge=1, description="Quantity requested")
    units: Optional[str] = Field(None, max_length=50, description="Unit of measure")
    start_date: Optional[date] = Field(None, description="Service start date")
    end_date: Optional[date] = Field(None, description="Service end date")

    @validator('procedure_code')
    def validate_procedure_code(cls, v):
        if not v or v.strip() == "":
            raise ValueError("Procedure code cannot be empty")
        return v.strip().upper()

    class Config:
        json_schema_extra = {
            "example": {
                "procedure_code": "99213",
                "description": "Office visit, established patient",
                "quantity": 1,
                "units": "visits",
                "start_date": "2025-10-25",
                "end_date": "2025-10-25"
            }
        }


class DiagnosisCode(BaseModel):
    """Diagnosis code information"""
    code: str = Field(..., max_length=20, description="ICD-10 diagnosis code")
    description: str = Field(..., max_length=500, description="Diagnosis description")
    is_primary: bool = Field(False, description="Whether this is the primary diagnosis")

    @validator('code')
    def validate_diagnosis_code(cls, v):
        if not v or v.strip() == "":
            raise ValueError("Diagnosis code cannot be empty")
        # Basic ICD-10 format validation (letter followed by digits and optional decimal)
        if not re.match(r'^[A-Z]\d{2}(\.\d{1,4})?$', v.strip().upper()):
            raise ValueError("Invalid ICD-10 code format")
        return v.strip().upper()

    class Config:
        json_schema_extra = {
            "example": {
                "code": "E11.9",
                "description": "Type 2 diabetes mellitus without complications",
                "is_primary": True
            }
        }


class ProcessingStatus(BaseModel):
    """Case processing status information"""
    status: CaseStatus = Field(CaseStatus.NEW, description="Current processing status")
    processing_result: Optional[ProcessingResult] = Field(None, description="Processing outcome")
    unable_to_process_reason: Optional[str] = Field(None, max_length=500, description="Reason if unable to process")
    assigned_user: Optional[str] = Field(None, max_length=200, description="User assigned to this case")
    created_at: datetime = Field(default_factory=datetime.utcnow, description="Creation timestamp")
    updated_at: datetime = Field(default_factory=datetime.utcnow, description="Last update timestamp")

    class Config:
        json_schema_extra = {
            "example": {
                "status": "new",
                "processing_result": "processed",
                "unable_to_process_reason": None,
                "assigned_user": "john.doe@example.com",
                "created_at": "2025-10-22T08:47:21.885Z",
                "updated_at": "2025-10-22T09:15:30.123Z"
            }
        }


class DocumentInfo(BaseModel):
    """Document metadata"""
    document_id: str = Field(..., description="Unique document identifier")
    filename: str = Field(..., max_length=255, description="Original filename")
    file_size: int = Field(..., ge=0, description="File size in bytes")
    blob_storage_url: str = Field(..., description="Azure Blob Storage URL")
    status: str = Field("uploaded", max_length=50, description="Document status")
    intake_queue_status: Optional[str] = Field(None, max_length=50, description="Intake queue status")
    created_date: datetime = Field(default_factory=datetime.utcnow, description="Upload date")
    modified_date: datetime = Field(default_factory=datetime.utcnow, description="Last modified date")
    created_by: Optional[str] = Field(None, max_length=200, description="Uploaded by user")
    modified_by: Optional[str] = Field(None, max_length=200, description="Last modified by user")

    class Config:
        json_schema_extra = {
            "example": {
                "document_id": "550e8400-e29b-41d4-a716-446655440004",
                "filename": "auth_request.pdf",
                "file_size": 245678,
                "blob_storage_url": "https://storage.blob.core.windows.net/intake/auth_request.pdf",
                "status": "uploaded",
                "intake_queue_status": "new",
                "created_date": "2025-10-22T08:47:21.885Z",
                "modified_date": "2025-10-22T08:47:21.885Z",
                "created_by": "system",
                "modified_by": "system"
            }
        }


class AIExtractions(BaseModel):
    """AI-extracted data from document"""
    member_info: Optional[MemberInfo] = None
    request_provider_info: Optional[RequestProviderInfo] = None
    service_provider_info: Optional[ServiceProviderInfo] = None
    request_info: Optional[RequestInfo] = None
    requested_items: Optional[List[RequestedItem]] = None
    diagnosis_codes: Optional[List[DiagnosisCode]] = None
    confidence_score: Optional[float] = Field(None, ge=0.0, le=1.0, description="Overall AI confidence score")
    extraction_timestamp: Optional[datetime] = Field(None, description="When AI extraction was performed")

    class Config:
        json_schema_extra = {
            "example": {
                "member_info": {"member_name": "John Doe", "dob": "1980-01-15"},
                "confidence_score": 0.95,
                "extraction_timestamp": "2025-10-22T08:50:00.000Z"
            }
        }


# ============================================================================
# REQUEST SCHEMAS
# ============================================================================

class CreateIntakeCaseRequest(BaseModel):
    """Request to create new intake case from Azure blob"""
    blob_url: str = Field(..., description="Azure Blob Storage URL of the document")
    document_type: Optional[str] = Field(None, max_length=100, description="Type of document (optional)")

    @validator('blob_url')
    def validate_blob_url(cls, v):
        if not v or not v.startswith(('http://', 'https://')):
            raise ValueError("Invalid blob URL format")
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "blob_url": "https://storage.blob.core.windows.net/intake/auth_request_20251022.pdf",
                "document_type": "authorization_request"
            }
        }


class UpdateIntakeCaseRequest(BaseModel):
    """Request to update intake case information"""
    source: Optional[str] = Field(None, max_length=20, description="Document source")
    health_plan: Optional[str] = Field(None, max_length=200, description="Health plan name")
    template: Optional[str] = Field(None, max_length=100, description="Template type")
    auth_number: Optional[str] = Field(None, max_length=100, description="Authorization number")
    member_name: Optional[str] = Field(None, max_length=200, description="Member name")
    received_date: Optional[datetime] = Field(None, description="Date received")
    priority: Optional[Priority] = Field(None, description="Priority level")
    status: Optional[CaseStatus] = Field(None, description="Case status")
    lapse_time: Optional[str] = Field(None, description="Time elapsed since receipt")
    document_id: Optional[str] = Field(None, description="Document identifier")
    assigned_user: Optional[str] = Field(None, max_length=200, description="Assigned user email")
    member_info: Optional[MemberInfo] = None
    request_provider_info: Optional[RequestProviderInfo] = None
    service_provider_info: Optional[ServiceProviderInfo] = None
    request_info: Optional[RequestInfo] = None
    requested_items: Optional[List[RequestedItem]] = None
    diagnosis_codes: Optional[List[DiagnosisCode]] = None

    class Config:
        json_schema_extra = {
            "example": {
                "source": "Fax",
                "health_plan": "Blue Cross",
                "priority": "expedited",
                "status": "in_progress",
                "assigned_user": "nurse@example.com",
                "member_info": {
                    "member_name": "John Doe",
                    "dob": "1980-01-15",
                    "health_plan_id": "HP123456",
                    "health_plan": "Blue Cross"
                }
            }
        }


class AIAnalysisRequest(BaseModel):
    """Request to run AI analysis on document"""
    blob: Optional[str] = Field(None, description="Blob data for AI analysis (optional, uses existing if not provided)")
    force_reanalysis: bool = Field(False, description="Force re-analysis even if already analyzed")

    class Config:
        json_schema_extra = {
            "example": {
                "blob": "base64_encoded_document_data",
                "force_reanalysis": False
            }
        }


class SubmitCaseRequest(BaseModel):
    """Request to submit case for clinical review"""
    auth_number: str = Field(..., description="Authorization number")
    member_info: MemberInfo
    request_provider_info: RequestProviderInfo
    service_provider_info: ServiceProviderInfo
    request_info: RequestInfo
    requested_items: List[RequestedItem] = Field(..., min_items=1, description="At least one requested item required")
    diagnosis_codes: List[DiagnosisCode] = Field(..., min_items=1, description="At least one diagnosis code required")
    processing_status: ProcessingStatus
    documents: List[DocumentInfo]

    class Config:
        json_schema_extra = {
            "example": {
                "auth_number": "AUTH-2024-1234",
                "member_info": {"member_name": "John Doe", "dob": "1980-01-15"},
                "requested_items": [{"procedure_code": "99213", "description": "Office visit"}],
                "diagnosis_codes": [{"code": "E11.9", "description": "Type 2 diabetes"}]
            }
        }


class SaveDraftRequest(BaseModel):
    """Request to save case as draft (partial data allowed)"""
    auth_number: Optional[str] = None
    member_info: Optional[MemberInfo] = None
    request_provider_info: Optional[RequestProviderInfo] = None
    service_provider_info: Optional[ServiceProviderInfo] = None
    request_info: Optional[RequestInfo] = None
    requested_items: Optional[List[RequestedItem]] = None
    diagnosis_codes: Optional[List[DiagnosisCode]] = None
    processing_status: Optional[ProcessingStatus] = None
    documents: Optional[List[DocumentInfo]] = None

    class Config:
        json_schema_extra = {
            "example": {
                "auth_number": "AUTH-2024-1234",
                "member_info": {"member_name": "John Doe", "dob": "1980-01-15"}
            }
        }


# ============================================================================
# RESPONSE SCHEMAS
# ============================================================================

class IntakeCaseDetailResponse(BaseModel):
    """Detailed intake case response"""
    auth_number: Optional[str] = None
    member_info: Optional[MemberInfo] = None
    request_provider_info: Optional[RequestProviderInfo] = None
    service_provider_info: Optional[ServiceProviderInfo] = None
    request_info: Optional[RequestInfo] = None
    requested_items: Optional[List[RequestedItem]] = None
    diagnosis_codes: Optional[List[DiagnosisCode]] = None
    ai_extractions: Optional[AIExtractions] = None
    processing_status: Optional[ProcessingStatus] = None
    documents: Optional[List[DocumentInfo]] = None

    class Config:
        json_schema_extra = {
            "example": {
                "auth_number": "AUTH-2024-1234",
                "member_info": {"member_name": "John Doe", "dob": "1980-01-15"},
                "processing_status": {"status": "new", "assigned_user": "nurse@example.com"}
            }
        }


class CreateIntakeCaseResponse(BaseModel):
    """Response after creating intake case"""
    document_id: str = Field(..., description="Unique document identifier")
    filename: str = Field(..., description="Document filename")
    file_size: int = Field(..., description="File size in bytes")
    blob_storage_url: str = Field(..., description="Azure Blob Storage URL")
    status: str = Field(..., description="Current status")
    intake_queue_status: str = Field(..., description="Intake queue status")
    created_date: datetime = Field(..., description="Creation timestamp")
    modified_date: datetime = Field(..., description="Last modified timestamp")
    created_by: str = Field(..., description="Created by user")
    modified_by: str = Field(..., description="Modified by user")

    class Config:
        json_schema_extra = {
            "example": {
                "document_id": "550e8400-e29b-41d4-a716-446655440004",
                "filename": "auth_request.pdf",
                "file_size": 245678,
                "blob_storage_url": "https://storage.blob.core.windows.net/intake/auth_request.pdf",
                "status": "uploaded",
                "intake_queue_status": "new",
                "created_date": "2025-10-22T08:47:21.885Z",
                "modified_date": "2025-10-22T08:47:21.885Z",
                "created_by": "system",
                "modified_by": "system"
            }
        }


class UpdateCaseResponse(BaseModel):
    """Response after updating case"""
    status: str = Field("success", description="Operation status")
    message: str = Field(..., description="Success message")
    document_id: Optional[str] = Field(None, description="Document ID")
    updated_at: Optional[datetime] = Field(None, description="Update timestamp")

    class Config:
        json_schema_extra = {
            "example": {
                "status": "success",
                "message": "Case updated successfully",
                "document_id": "550e8400-e29b-41d4-a716-446655440004",
                "updated_at": "2025-10-22T09:30:00.000Z"
            }
        }


class AIAnalysisResponse(BaseModel):
    """Response after AI analysis"""
    status: str = Field("success", description="Analysis status")
    message: str = Field(..., description="Status message")
    extractions: Optional[AIExtractions] = Field(None, description="Extracted data")
    confidence_score: Optional[float] = Field(None, ge=0.0, le=1.0, description="Overall confidence")
    analysis_timestamp: datetime = Field(default_factory=datetime.utcnow, description="Analysis timestamp")

    class Config:
        json_schema_extra = {
            "example": {
                "status": "success",
                "message": "AI analysis completed successfully",
                "confidence_score": 0.95,
                "analysis_timestamp": "2025-10-22T08:50:00.000Z"
            }
        }


class SubmitCaseResponse(BaseModel):
    """Response after submitting case for clinical review"""
    message: str = Field(..., description="Submission confirmation message")
    case: IntakeCaseDetailResponse = Field(..., description="Submitted case details")
    clinical_queue_id: Optional[str] = Field(None, description="Clinical review queue ID")
    submitted_at: datetime = Field(default_factory=datetime.utcnow, description="Submission timestamp")

    class Config:
        json_schema_extra = {
            "example": {
                "message": "Case submitted for clinical review",
                "clinical_queue_id": "CLN-2024-5678",
                "submitted_at": "2025-10-22T10:00:00.000Z"
            }
        }


class DraftSaveResponse(BaseModel):
    """Response after saving draft"""
    message: str = Field("Draft saved successfully", description="Save confirmation message")
    saved_at: datetime = Field(default_factory=datetime.utcnow, description="Save timestamp")
    document_id: Optional[str] = Field(None, description="Document ID")

    class Config:
        json_schema_extra = {
            "example": {
                "message": "Draft saved successfully",
                "saved_at": "2025-10-22T09:45:00.000Z",
                "document_id": "550e8400-e29b-41d4-a716-446655440004"
            }
        }


# ============================================================================
# QUEUE SCHEMAS (from existing intake.py)
# ============================================================================

class IntakeQueueItem(BaseModel):
    """Single item in intake queue"""
    source: Optional[str] = None
    health_plan: Optional[str] = None
    document_id: Optional[str] = None
    auth_number: Optional[str] = None
    template: Optional[str] = None
    member_name: Optional[str] = None
    dob: Optional[date] = None
    queue_time: Optional[datetime] = None
    received_date: Optional[datetime] = None
    priority: Optional[str] = None
    lapse_time: Optional[str] = None
    lapse_hour: Optional[str] = None  # Added to match spec
    status: Optional[str] = None
    assigned_to: Optional[str] = None

    class Config:
        json_schema_extra = {
            "example": {
                "source": "Fax",
                "health_plan": "Plan A",
                "document_id": "550e8400-e29b-41d4-a716-446655440004",
                "auth_number": "AUTH-2024-1234",
                "template": "IP Hospital (REV 0110)",
                "member_name": "John Doe",
                "dob": "1980-01-15",
                "received_date": "2025-10-21T17:40:24.455Z",
                "priority": "expedited",
                "lapse_time": "2 hours",
                "status": "new",
                "assigned_to": "John Doe"
            }
        }


class Pagination(BaseModel):
    """Pagination metadata"""
    page: int = Field(..., ge=1, description="Current page number")
    page_size: int = Field(..., ge=1, le=100, description="Items per page")
    total_items: int = Field(..., ge=0, description="Total number of items")
    total_pages: int = Field(..., ge=0, description="Total number of pages")
    has_next: bool = Field(..., description="Whether there is a next page")
    has_previous: bool = Field(..., description="Whether there is a previous page")

    class Config:
        json_schema_extra = {
            "example": {
                "page": 1,
                "page_size": 10,
                "total_items": 150,
                "total_pages": 15,
                "has_next": True,
                "has_previous": False
            }
        }


class Statistics(BaseModel):
    """Queue statistics"""
    total_cases: int = Field(..., ge=0, description="Total number of cases")
    available_cases: int = Field(..., ge=0, description="Available cases for processing")
    expedited_cases: int = Field(..., ge=0, description="Expedited priority cases")


class IntakeQueueResponse(BaseModel):
    """Intake queue response with pagination and statistics"""
    cases: List[IntakeQueueItem] = Field(..., description="List of queue items")
    pagination: Pagination = Field(..., description="Pagination information")
    statistics: Statistics = Field(..., description="Queue statistics")


# ============================================================================
# DOCUMENT MANAGEMENT SCHEMAS
# ============================================================================

class DocumentUploadRequest(BaseModel):
    """Request to upload document or register SFTP path"""
    sftp_path: Optional[str] = Field(None, description="SFTP path to document")
    document_type: Optional[str] = Field(None, description="Type of document")
    auth_number: Optional[str] = Field(None, description="Authorization number")
    
    class Config:
        json_schema_extra = {
            "example": {
                "sftp_path": "/incoming/partnerA/file.pdf",
                "document_type": "clinical_document",
                "auth_number": "AUTH-2024-1234"
            }
        }


class DocumentUploadResponse(BaseModel):
    """Response after document upload"""
    document_id: str = Field(..., description="Unique document identifier")
    status: str = Field("queued", description="Document status")
    
    class Config:
        json_schema_extra = {
            "example": {
                "document_id": "550e8400-e29b-41d4-a716-446655440004",
                "status": "queued"
            }
        }


class DocumentMetadataResponse(BaseModel):
    """Document metadata response"""
    document_id: str = Field(..., description="Document identifier")
    filename: str = Field(..., description="Original filename")
    file_size: int = Field(..., description="File size in bytes")
    checksum: str = Field(..., description="File checksum (MD5 or SHA256)")
    transfer_status: str = Field(..., description="Transfer status")
    sftp_path: Optional[str] = Field(None, description="SFTP path if applicable")
    blob_url: Optional[str] = Field(None, description="Blob storage URL if applicable")
    created_date: datetime = Field(..., description="Upload date")
    modified_date: datetime = Field(..., description="Last modified date")
    
    class Config:
        json_schema_extra = {
            "example": {
                "document_id": "550e8400-e29b-41d4-a716-446655440004",
                "filename": "auth_request.pdf",
                "file_size": 245678,
                "checksum": "5d41402abc4b2a76b9719d911017c592",
                "transfer_status": "completed",
                "sftp_path": "/incoming/partnerA/file.pdf",
                "blob_url": "https://storage.blob.core.windows.net/intake/file.pdf",
                "created_date": "2025-10-22T08:47:21.885Z",
                "modified_date": "2025-10-22T08:47:21.885Z"
            }
        }

