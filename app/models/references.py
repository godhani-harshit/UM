from sqlalchemy import (
    Column,
    String,
    Integer,
    Boolean,
    DateTime,
    Text,
    JSON,
)
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.sql import func
from app.core.database import Base
import uuid


# =======================================================
# UMConfig
# =======================================================
class UMConfig(Base):
    __tablename__ = "um_config"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    config_key = Column(String(100), unique=True, nullable=False)
    config_value = Column(JSON, nullable=False, default=dict)
    is_active = Column(Boolean, default=True, nullable=False)

    deleted = Column(String(1), default="n")

    creatorid = Column(String(30), default="system")
    createddate = Column(DateTime, server_default=func.now())
    createddate_as_number = Column(String(14))

    lastupdateid = Column(String(30), default="system")
    lastupdatedate = Column(DateTime, server_default=func.now(), onupdate=func.now())
    lastupdatedate_as_number = Column(String(14))


# =======================================================
# HealthPlan
# =======================================================
class HealthPlan(Base):
    __tablename__ = "um_health_plans"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    contract_id = Column(String(50), unique=True, nullable=False)
    organization_marketing_name = Column(String(255), nullable=False)
    geographic_name = Column(String(255), nullable=False)

    is_active = Column(Boolean, default=True, nullable=False)
    deleted = Column(String(1), default="n")

    creatorid = Column(String(30), default="system")
    createddate = Column(DateTime, server_default=func.now())
    createddate_as_number = Column(String(14))

    lastupdateid = Column(String(30), default="system")
    lastupdatedate = Column(DateTime, server_default=func.now(), onupdate=func.now())
    lastupdatedate_as_number = Column(String(14))


# =======================================================
# Provider
# =======================================================
class Provider(Base):
    __tablename__ = "um_providers"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    npi = Column(String(10), unique=True, nullable=False)
    full_name = Column(String(255), nullable=False)

    phone = Column(String(20))
    fax = Column(String(20))
    email = Column(String(255))

    is_active = Column(Boolean, default=True, nullable=False)
    deleted = Column(String(1), default="n")

    creatorid = Column(String(30), default="system")
    createddate = Column(DateTime, server_default=func.now())
    createddate_as_number = Column(String(14))

    lastupdateid = Column(String(30), default="system")
    lastupdatedate = Column(DateTime, server_default=func.now(), onupdate=func.now())
    lastupdatedate_as_number = Column(String(14))


# =======================================================
# DiagnosisCode
# =======================================================
class DiagnosisCode(Base):
    __tablename__ = "um_diagnosis_codes"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code_id = Column(String(20), unique=True, nullable=False)
    description = Column(String(500), nullable=False)
    long_description = Column(Text, nullable=True)

    is_active = Column(Boolean, default=True, nullable=False)
    deleted = Column(String(1), default="n")

    creatorid = Column(String(30), default="system")
    createddate = Column(DateTime, server_default=func.now())
    createddate_as_number = Column(String(14))

    lastupdateid = Column(String(30), default="system")
    lastupdatedate = Column(DateTime, server_default=func.now(), onupdate=func.now())
    lastupdatedate_as_number = Column(String(14))


# =======================================================
# ProcedureCode
# =======================================================
class ProcedureCode(Base):
    __tablename__ = "um_procedure_codes"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code_id = Column(String(20), unique=True, nullable=False)
    description = Column(String(500), nullable=False)
    long_description = Column(Text)
    group_description = Column(String(255))

    code_type = Column(String(10), nullable=False)  # CPT or REV

    is_active = Column(Boolean, default=True, nullable=False)
    deleted = Column(String(1), default="n")

    creatorid = Column(String(30), default="system")
    createddate = Column(DateTime, server_default=func.now())
    createddate_as_number = Column(String(14))

    lastupdateid = Column(String(30), default="system")
    lastupdatedate = Column(DateTime, server_default=func.now(), onupdate=func.now())
    lastupdatedate_as_number = Column(String(14))


# =======================================================
# Template
# =======================================================
class Template(Base):
    __tablename__ = "um_templates"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    template_name = Column(String(255), unique=True, nullable=False)
    template_type = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)

    form_schema = Column(JSON, nullable=False, default=dict)

    is_active = Column(Boolean, default=True, nullable=False)
    deleted = Column(String(1), default="n")

    creatorid = Column(String(30), default="system")
    createddate = Column(DateTime, server_default=func.now())
    createddate_as_number = Column(String(14))

    lastupdateid = Column(String(30), default="system")
    lastupdatedate = Column(DateTime, server_default=func.now(), onupdate=func.now())
    lastupdatedate_as_number = Column(String(14))
