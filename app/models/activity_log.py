from uuid import uuid4
from datetime import datetime
from app.core.database import Base
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy import Column, String, Text, DateTime, Numeric, ForeignKey


class ActivityLog(Base):
    __tablename__ = "activity_logs"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True),primary_key=True,default=uuid4,)
    user_id = Column(PG_UUID(as_uuid=True),ForeignKey("um.um_users.id"),nullable=True,index=True,)
    action = Column(String(255), nullable=False)
    entity = Column(String(100), nullable=True)
    entity_id = Column(PG_UUID(as_uuid=True), nullable=True)
    details = Column(Text, nullable=True)
    ip_address = Column(String(50), nullable=True)
    user_agent = Column(Text, nullable=True)
    deleted = Column(String(1), default="n", nullable=False)
    creatorid = Column(String(30), default="CURRENT_USER", nullable=False)
    createddate = Column(DateTime, default=datetime.utcnow, nullable=False)
    createddate_as_number = Column(Numeric, nullable=True)
    lastupdateid = Column(String(30), default="CURRENT_USER", nullable=False)
    lastupdatedate = Column(DateTime, default=datetime.utcnow, nullable=False)
    lastupdatedate_as_number = Column(Numeric, nullable=True)