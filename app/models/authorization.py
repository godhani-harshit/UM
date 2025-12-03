import uuid
from sqlalchemy.sql import func
from app.core.database import Base 
from sqlalchemy import Column, BigInteger, String, DateTime, Boolean, Integer, Date, JSON, Identity


class Authorization(Base):
    __tablename__ = "um_authorizations"
    __table_args__ = {"schema": "um"}


    id = Column(BigInteger,Identity(start=1, cycle=False),primary_key=True)
    document_id = Column(String(100),unique=True,nullable=False,default=lambda: str(uuid.uuid4()))
    source = Column(String(20), nullable=True)
    file_name = Column(String(255), nullable=True)
    file_url = Column(String(500), nullable=True)
    file_size = Column(BigInteger, nullable=True)
    file_arrival_time = Column(DateTime, server_default=func.now(), nullable=False)
    authorization_number = Column(String(100), nullable=True)
    patient_id = Column(String(100), nullable=True)
    status = Column(String(100), default="Queued", nullable=True)
    priority = Column(String(50), default="Undetermined", nullable=False)
    member_name = Column(String(200), default="Unassigned", nullable=True)
    dob = Column(Date, nullable=False)
    healthplan_id = Column(String(100), default="UNKNOWN", nullable=False)
    health_plan = Column(String(200), default="UNKNOWN", nullable=False)
    requesting_npi = Column(String(20), default="UNKNOWN", nullable=False)
    requesting_name = Column(String(200), default="UNKNOWN", nullable=False)
    servicing_name = Column(String(200), nullable=True)
    template_type = Column(String(100), default="Undetermined", nullable=False)
    receipt_datetime = Column(DateTime, server_default=func.now(), nullable=False)
    start_of_care = Column(Date, nullable=True)
    result = Column(String(100), nullable=True)
    assigned_user = Column(String(200), nullable=True)
    procedure_code = Column(String(500), nullable=True)
    determination = Column(String(50), nullable=True)
    md_determination = Column(String(50), nullable=True)
    escalation_date = Column(DateTime, nullable=True)
    escalation_type = Column(String(50), nullable=True)
    nurse_reviewer = Column(String(200), nullable=True)
    original_reviewer = Column(String(200), nullable=True)
    review_date = Column(DateTime, nullable=True)
    complexity = Column(String(20), nullable=True)
    form_data = Column(JSON, nullable=False, default=dict)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    created_by = Column(String(200), nullable=True)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
    updated_by = Column(String(200), nullable=True)
    is_deleted = Column(Boolean, default=False, nullable=False)
    deleted_at = Column(DateTime, nullable=True)
    deleted_by = Column(String(200), nullable=True)
    version = Column(Integer, default=1, nullable=False)

    def __repr__(self):
        return (
            f"<Authorization(document_id='{self.document_id}', "
            f"source='{self.source}', status='{self.status}')>"
        )