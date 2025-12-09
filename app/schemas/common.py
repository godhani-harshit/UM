"""
Shared/Common schemas used across multiple workflows
"""

from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime, date


class MemberInfo(BaseModel):
    """Member/patient information"""

    member_name: Optional[str] = None
    dob: Optional[str] = None
    health_plan_id: Optional[str] = None
    health_plan: Optional[str] = None
    authorization_number: Optional[str] = None


class ContactInfo(BaseModel):
    """Contact information"""

    request_method: Optional[str] = None
    contact_name: Optional[str] = None
    contact_phone: Optional[str] = None
    contact_facility: Optional[str] = None
    contact_fax: Optional[str] = None
    contact_email: Optional[EmailStr] = None


class RequestProviderInfo(BaseModel):
    """Requesting provider information"""

    requesting_provider: Optional[str] = None
    requesting_provider_npi: Optional[str] = None
    requesting_phone: Optional[str] = None
    requesting_fax: Optional[str] = None
    requesting_email: Optional[str] = None


class ServiceProviderInfo(BaseModel):
    """Servicing provider information"""

    servicing_provider: Optional[str] = None
    servicing_provider_npi: Optional[str] = None
    servicing_phone: Optional[str] = None
    servicing_fax: Optional[str] = None
    servicing_email: Optional[str] = None


class RequestInfo(BaseModel):
    """Request information"""

    template_type: Optional[str] = None
    received_datetime: Optional[datetime] = None
    start_of_service: Optional[datetime] = None
    priority: Optional[str] = None


class RequestedItem(BaseModel):
    """Requested service or item"""

    cpt_rev: Optional[str] = None
    dosage: Optional[str] = None
    units: Optional[str] = None
    frequency: Optional[str] = None
    duration: Optional[str] = None


class DiagnosisCode(BaseModel):
    """Diagnosis code information"""

    code: Optional[str] = None
    description: Optional[str] = None


class DocumentInfo(BaseModel):
    """Document metadata"""

    document_id: str
    document_type: Optional[str] = None
    file_name: str
    blob_url: str
    uploaded_at: datetime
    uploaded_by: Optional[str] = None


class MedicationCalculation(BaseModel):
    """Medication calculation details"""

    medications_iv_fluids: Optional[str] = None
    cpt_hcps: Optional[str] = None
    dose_requested: Optional[float] = None
    frequency: Optional[float] = None
    frequency_type: Optional[str] = None
    frequency_duration: Optional[float] = None
    description_dose: Optional[float] = None
    total_units: Optional[float] = None
    unit_type: Optional[str] = None


class WoundAssessment(BaseModel):
    """Wound assessment details"""

    duration: Optional[str] = None
    length: Optional[float] = None
    width: Optional[float] = None
    depth: Optional[float] = None
    location: Optional[str] = None
    description: Optional[str] = None
    exudate: Optional[str] = None
    progress: Optional[str] = None
    treatment_plan: Optional[str] = None
    additional_notes: Optional[str] = None


class PhysicalTherapyAssessment(BaseModel):
    """Physical therapy assessment"""

    review_number: Optional[int] = None
    date: Optional[date] = None
    bed_mobility: Optional[str] = None
    transfers: Optional[str] = None
    ambulation: Optional[str] = None
    ambulation_distance: Optional[str] = None
    level_of_func_ambulation: Optional[str] = None
    assistive_device: Optional[str] = None
    level_of_func_stairs: Optional[str] = None
    bathing: Optional[str] = None
    dressing_upper_body: Optional[str] = None
    dressing_lower_body: Optional[str] = None
    toileting: Optional[str] = None
    toilet_transfers: Optional[str] = None
    additional_notes: Optional[str] = None


class ClinicalInfo(BaseModel):
    """Clinical information"""

    template: Optional[str] = None
    review_type: Optional[str] = None
    priority: Optional[str] = None
    brief_clinical_course: Optional[str] = None
    past_medical_history: Optional[str] = None
    skilled_needs: Optional[str] = None
    radiology_diagnostics: Optional[str] = None
    ventilator: Optional[str] = None
    speech_therapy: Optional[str] = None
    last_therapy_certification: Optional[str] = None
    discharge_plan_barriers: Optional[str] = None
    assessment_plan: Optional[str] = None
    concurrent_updates: Optional[str] = None
    additional_notes: Optional[str] = None
    readmission: Optional[str] = None
    criteria: Optional[str] = None
    medications: Optional[List[MedicationCalculation]] = None
    wounds: Optional[List[WoundAssessment]] = None
    physical_therapy: Optional[List[PhysicalTherapyAssessment]] = None
