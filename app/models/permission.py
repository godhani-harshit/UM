from sqlalchemy import (
    Column,
    String,
    Text,
    DateTime,
    Integer,
    ForeignKey,
)
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from datetime import datetime
from uuid import uuid4
from app.core.database import Base


class Permission(Base):
    __tablename__ = "permissions"
    __table_args__ = {"schema": "um"}

    id = Column(
        PG_UUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
        nullable=False,
    )

    permission_key = Column(String(255), unique=True, nullable=False)
    permission_code = Column(String(255), nullable=True)
    permission_name = Column(String(255), nullable=True)
    description = Column(Text, nullable=True)

    module_id = Column(
        PG_UUID(as_uuid=True),
        ForeignKey("um.modules.id", ondelete="SET NULL"),
        nullable=True,
    )

    deleted = Column(String(1), default="n", nullable=False)

    # Audit fields
    creatorid = Column(String(100), nullable=True)
    createddate = Column(DateTime, default=datetime.utcnow, nullable=False)
    createddate_as_number = Column(Integer, nullable=True)
    lastupdateid = Column(String(100), nullable=True)
    lastupdatedate = Column(DateTime, default=datetime.utcnow, nullable=False)
    lastupdatedate_as_number = Column(Integer, nullable=True)
