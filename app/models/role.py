from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from app.core.database import Base  # Your SQLAlchemy declarative base


class Role(Base):
    __tablename__ = "um_roles"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    role_key = Column(String(100), unique=True, nullable=False)
    role_display_name = Column(String(255))
    description = Column(String)
    deleted = Column(String(1), default="n")

    # Audit fields
    creatorid = Column(String(50))
    createddate = Column(DateTime, default=datetime.utcnow)
    createddate_as_number = Column(String(14))
    lastupdateid = Column(String(50))
    lastupdatedate = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    lastupdatedate_as_number = Column(String(14))

    # Relationship with User through link table
    users = relationship(
        "User",
        secondary="um.um_user_roles",  # Schema-qualified table
        back_populates="roles",
        lazy="selectin"
    )
