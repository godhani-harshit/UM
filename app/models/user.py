from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from app.core.database import Base  # Your SQLAlchemy declarative base


class User(Base):
    __tablename__ = "um_users"
    __table_args__ = {"schema": "um"}

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, index=True, nullable=False)
    first_name = Column(String(100))
    last_name = Column(String(100))
    full_name = Column(String(255))
    password_hash = Column(String(500))
    is_active = Column(Boolean, default=True, nullable=False)
    role_name = Column(String(100))
    deleted = Column(String(1), default="n")

    # Audit fields
    creatorid = Column(String(50))
    createddate = Column(DateTime, default=datetime.utcnow)
    createddate_as_number = Column(String(14))
    lastupdateid = Column(String(50))
    lastupdatedate = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    lastupdatedate_as_number = Column(String(14))

    # Many-to-many relationship with Role
    roles = relationship(
        "Role",
        secondary="um.um_user_roles",  # Schema-qualified table
        back_populates="users",
        lazy="selectin"
    )
