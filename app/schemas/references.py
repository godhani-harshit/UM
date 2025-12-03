from uuid import UUID
from decimal import Decimal
from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, field_validator


class HealthPlanBase(BaseModel):
    contract_id: str
    organization_marketing_name: str
    geographic_name: str
    is_active: bool = True


class HealthPlanCreate(HealthPlanBase):
    pass

class HealthPlanUpdate(BaseModel):
    contract_id: Optional[str] = None
    organization_marketing_name: Optional[str] = None
    geographic_name: Optional[str] = None
    is_active: Optional[bool] = None


class HealthPlanResponse(HealthPlanBase):
    id: UUID
    deleted: Optional[str] = None
    creatorid: Optional[str] = None
    createddate: Optional[datetime] = None
    createddate_as_number: Optional[str] = None
    lastupdateid: Optional[str] = None
    lastupdatedate: Optional[datetime] = None
    lastupdatedate_as_number: Optional[str] = None
    
    @field_validator('createddate_as_number', 'lastupdatedate_as_number', mode='before')
    @classmethod
    def convert_decimal_to_string(cls, v: Any) -> Optional[str]:
        """Convert Decimal to string if needed"""
        if v is None:
            return None
        if isinstance(v, Decimal):
            return str(v)
        return v


class ProviderBase(BaseModel):
    npi: str
    full_name: str
    phone: Optional[str] = None
    fax: Optional[str] = None
    email: Optional[str] = None
    is_active: bool = True

class ProviderCreate(ProviderBase):
    pass

class ProviderUpdate(BaseModel):
    npi: Optional[str] = None
    full_name: Optional[str] = None
    phone: Optional[str] = None
    fax: Optional[str] = None
    email: Optional[str] = None
    is_active: Optional[bool] = None


class ProviderResponse(ProviderBase):
    id: UUID
    deleted: Optional[str] = None
    creatorid: Optional[str] = None
    createddate: Optional[datetime] = None
    createddate_as_number: Optional[str] = None
    lastupdateid: Optional[str] = None
    lastupdatedate: Optional[datetime] = None
    lastupdatedate_as_number: Optional[str] = None
    

    @field_validator('createddate_as_number', 'lastupdatedate_as_number', mode='before')
    @classmethod
    def convert_decimal_to_string(cls, v: Any) -> Optional[str]:
        """Convert Decimal to string if needed"""
        if v is None:
            return None
        if isinstance(v, Decimal):
            return str(v)
        return v


class DiagnosisCodeBase(BaseModel):
    code_id: str
    description: str
    long_description: Optional[str] = None
    is_active: bool = True

class DiagnosisCodeCreate(DiagnosisCodeBase):
    pass


class DiagnosisCodeUpdate(BaseModel):
    code_id: Optional[str] = None
    description: Optional[str] = None
    long_description: Optional[str] = None
    is_active: Optional[bool] = None


class DiagnosisCodeResponse(DiagnosisCodeBase):
    id: UUID
    deleted: Optional[str] = None
    creatorid: Optional[str] = None
    createddate: Optional[datetime] = None
    createddate_as_number: Optional[str] = None
    lastupdateid: Optional[str] = None
    lastupdatedate: Optional[datetime] = None
    lastupdatedate_as_number: Optional[str] = None
    
    @field_validator('createddate_as_number', 'lastupdatedate_as_number', mode='before')
    @classmethod
    def convert_decimal_to_string(cls, v: Any) -> Optional[str]:
        """Convert Decimal to string if needed"""
        if v is None:
            return None
        if isinstance(v, Decimal):
            return str(v)
        return v


class ProcedureCodeBase(BaseModel):
    code_id: str
    description: str
    long_description: Optional[str] = None
    group_description: Optional[str] = None
    code_type: str
    is_active: bool = True


class ProcedureCodeCreate(ProcedureCodeBase):
    pass


class ProcedureCodeUpdate(BaseModel):
    code_id: Optional[str] = None
    description: Optional[str] = None
    long_description: Optional[str] = None
    group_description: Optional[str] = None
    code_type: Optional[str] = None
    is_active: Optional[bool] = None


class ProcedureCodeResponse(ProcedureCodeBase):
    id: UUID
    deleted: Optional[str] = None
    creatorid: Optional[str] = None
    createddate: Optional[datetime] = None
    createddate_as_number: Optional[str] = None
    lastupdateid: Optional[str] = None
    lastupdatedate: Optional[datetime] = None
    lastupdatedate_as_number: Optional[str] = None
    
    @field_validator('createddate_as_number', 'lastupdatedate_as_number', mode='before')
    @classmethod
    def convert_decimal_to_string(cls, v: Any) -> Optional[str]:
        """Convert Decimal to string if needed"""
        if v is None:
            return None
        if isinstance(v, Decimal):
            return str(v)
        return v


class TemplateBase(BaseModel):
    template_name: str
    template_type: str
    description: Optional[str] = None
    form_schema: dict
    is_active: bool = True


class TemplateCreate(TemplateBase):
    pass


class TemplateUpdate(BaseModel):
    template_name: Optional[str] = None
    template_type: Optional[str] = None
    description: Optional[str] = None
    form_schema: Optional[dict] = None
    is_active: Optional[bool] = None


class TemplateResponse(TemplateBase):
    id: UUID
    deleted: Optional[str] = None
    creatorid: Optional[str] = None
    createddate: Optional[datetime] = None
    createddate_as_number: Optional[str] = None
    lastupdateid: Optional[str] = None
    lastupdatedate: Optional[datetime] = None
    lastupdatedate_as_number: Optional[str] = None
    
    @field_validator('createddate_as_number', 'lastupdatedate_as_number', mode='before')
    @classmethod
    def convert_decimal_to_string(cls, v: Any) -> Optional[str]:
        """Convert Decimal to string if needed"""
        if v is None:
            return None
        if isinstance(v, Decimal):
            return str(v)
        return v