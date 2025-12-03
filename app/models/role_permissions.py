from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from datetime import datetime
import uuid
from app.core.database import Base  # Your SQLAlchemy declarative base


class RolePermission(Base):
    __tablename__ = "role_permissions"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    role_id = Column(PG_UUID(as_uuid=True), ForeignKey("um.um_roles.id"), nullable=False)
    permission_id = Column(PG_UUID(as_uuid=True), ForeignKey("um.permissions.id"), nullable=False)

    # Permission flags
    can_read = Column(Boolean, default=True, nullable=False)
    can_create = Column(Boolean, default=False, nullable=False)
    can_update = Column(Boolean, default=False, nullable=False)
    can_delete = Column(Boolean, default=False, nullable=False)

    deleted = Column(String(1), default="n")

    # Audit Fields
    creatorid = Column(String(50), default="system")
    createddate = Column(DateTime, default=datetime.utcnow)
    createddate_as_number = Column(String(14))
    lastupdateid = Column(String(50), default="system")
    lastupdatedate = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    lastupdatedate_as_number = Column(String(14))