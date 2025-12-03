from sqlalchemy import Column, String, Integer, DateTime
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from datetime import datetime
import uuid
from app.core.database import Base  # Your SQLAlchemy declarative base


class Workflow(Base):
    __tablename__ = "workflows"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    workflow_key = Column(String(100), unique=True, nullable=False)
    workflow_name = Column(String(255), nullable=False)
    description = Column(String)
    display_order = Column(Integer, default=0)
    deleted = Column(String(1), default="n")

    # Audit fields
    creatorid = Column(String(50))
    createddate = Column(DateTime, default=datetime.utcnow)
    createddate_as_number = Column(String(14))
    lastupdateid = Column(String(50))
    lastupdatedate = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    lastupdatedate_as_number = Column(String(14))
