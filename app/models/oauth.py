from sqlalchemy import (
    Column,
    Integer,
    String,
    DateTime,
    ForeignKey,
    Text,
)
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from datetime import datetime
from app.core.database import Base


# =======================================================
# OAuth Provider Model
# =======================================================
class OAuthProvider(Base):
    __tablename__ = "oauth_providers"
    __table_args__ = {"schema": "um"}

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    client_id = Column(String(255), nullable=False)
    client_secret = Column(String(500), nullable=False)
    authority = Column(String(500), nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    # Relationship
    tokens = relationship("OAuthToken", back_populates="provider")


# =======================================================
# OAuth Token Model
# =======================================================
class OAuthToken(Base):
    __tablename__ = "oauth_tokens"
    __table_args__ = {"schema": "um"}

    id = Column(Integer, primary_key=True, index=True)

    # Foreign Keys (correct schema paths)
    user_id = Column(
        PG_UUID(as_uuid=True),
        ForeignKey("um.um_users.id", ondelete="CASCADE"),
        nullable=False,
    )
    provider_id = Column(
        Integer,
        ForeignKey("um.oauth_providers.id", ondelete="CASCADE"),
        nullable=False,
    )

    access_token = Column(Text, nullable=False)
    refresh_token = Column(Text, nullable=True)
    expires_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    provider = relationship("OAuthProvider", back_populates="tokens")
