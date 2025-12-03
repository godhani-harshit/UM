from sqlalchemy import Column, String, Integer, Text, DateTime
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from datetime import datetime
from uuid import uuid4
from app.core.database import Base

class Module(Base):
    __tablename__ = "modules"
    __table_args__ = {"schema": "um"}

    id = Column(
        PG_UUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
        nullable=False,
    )
    module_code = Column(String(50), nullable=False)
    module_name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    display_order = Column(Integer, nullable=True)
    deleted = Column(String(1), default="n", nullable=True)

    # Audit fields
    creatorid = Column(String(30), default="CURRENT_USER", nullable=True)
    createddate = Column(DateTime, default=datetime.utcnow, nullable=True)
    createddate_as_number = Column(Integer, nullable=True)
    lastupdateid = Column(String(30), default="CURRENT_USER", nullable=True)
    lastupdatedate = Column(DateTime, default=datetime.utcnow, nullable=True)
    lastupdatedate_as_number = Column(Integer, nullable=True)
