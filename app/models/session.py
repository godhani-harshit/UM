from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import DeclarativeBase
from datetime import datetime
import uuid
from app.core.database import Base  # Your SQLAlchemy declarative base


class UserSession(Base):
    __tablename__ = "user_sessions"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(PG_UUID(as_uuid=True), ForeignKey("um.um_users.id"), nullable=False)

    access_token = Column(String(500), nullable=False)
    refresh_token = Column(String(500), nullable=False)
    ip_address = Column(String(50))
    user_agent = Column(String)
    expires_at = Column(DateTime)

    deleted = Column(String(1), default="n")

    # Audit fields
    creatorid = Column(String(50))
    createddate = Column(DateTime, default=datetime.utcnow)
    createddate_as_number = Column(String(14))
    lastupdateid = Column(String(50))
    lastupdatedate = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    lastupdatedate_as_number = Column(String(14))
