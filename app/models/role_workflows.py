from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from datetime import datetime
import uuid
from app.core.database import Base  # Your SQLAlchemy declarative base


class RoleWorkflow(Base):
    __tablename__ = "role_workflows"
    __table_args__ = {"schema": "um"}

    # Primary Key
    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    role_id = Column(PG_UUID(as_uuid=True), ForeignKey("um.um_roles.id"), nullable=False)
    workflow_id = Column(PG_UUID(as_uuid=True), ForeignKey("um.workflows.id"), nullable=False)

    # Soft Delete
    deleted = Column(String(1), default="n")

    # Audit Fields
    creatorid = Column(String(50), default="system")
    createddate = Column(DateTime, default=datetime.utcnow)
    createddate_as_number = Column(String(14))
    lastupdateid = Column(String(50), default="system")
    lastupdatedate = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    lastupdatedate_as_number = Column(String(14))