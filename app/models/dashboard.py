from app.core.database import Base
from sqlalchemy.orm import relationship
from sqlalchemy import Column,Integer,String,DateTime,Text,ForeignKey


# =======================================================
# Workflow Model
# =======================================================
class Workflow(Base):
    """
    Workflow database model
    Represents UM workflows like intake, clinical review, etc.
    """
    __tablename__ = "workflows"
    __table_args__ = {'schema': 'um'}
    
    id = Column(Integer, primary_key=True, index=True)

    # Core workflow info
    workflow_key = Column(String(100), unique=True, nullable=False, index=True)
    workflow_name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    display_order = Column(Integer, default=999)

    # UI configuration
    icon = Column(String(100))
    route_path = Column(String(255))
    button_text = Column(String(100))
    button_icon = Column(String(100))

    # Soft delete flag
    deleted = Column(String(1), default="n", nullable=False)

    # Audit fields
    creatorid = Column(Integer, nullable=True)
    createddate = Column(DateTime, nullable=True)
    createddate_as_number = Column(Integer, nullable=True)
    lastupdateid = Column(Integer, nullable=True)
    lastupdatedate = Column(DateTime, nullable=True)
    lastupdatedate_as_number = Column(Integer, nullable=True)

    # Relationships
    role_workflows = relationship("RoleWorkflow", back_populates="workflow")


# =======================================================
# Role Model
# =======================================================
class Role(Base):
    """
    Role database model
    """
    __tablename__ = "um_roles"
    __table_args__ = {'schema': 'um'}

    id = Column(Integer, primary_key=True, index=True)

    role_key = Column(String(100), unique=True, nullable=False)
    role_display_name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    role_code = Column(String(50), nullable=True)

    deleted = Column(String(1), default="n")

    creatorid = Column(Integer, nullable=True)
    createddate = Column(DateTime, nullable=True)
    createddate_as_number = Column(Integer, nullable=True)
    lastupdateid = Column(Integer, nullable=True)
    lastupdatedate = Column(DateTime, nullable=True)
    lastupdatedate_as_number = Column(Integer, nullable=True)

    # Relationships
    role_workflows = relationship("RoleWorkflow", back_populates="role")


# =======================================================
# RoleWorkflow Join Table
# =======================================================
class RoleWorkflow(Base):
    """
    Role-Workflow relationship model
    """
    __tablename__ = "role_workflows"
    __table_args__ = {'schema': 'um'}

    id = Column(Integer, primary_key=True, index=True)

    role_id = Column(
        Integer,
        ForeignKey("um.um_roles.id", ondelete="CASCADE"),
        nullable=False
    )
    workflow_id = Column(
        Integer,
        ForeignKey("um.workflows.id", ondelete="CASCADE"),
        nullable=False
    )

    deleted = Column(String(1), default="n")

    creatorid = Column(Integer, nullable=True)
    createddate = Column(DateTime, nullable=True)
    createddate_as_number = Column(Integer, nullable=True)
    lastupdateid = Column(Integer, nullable=True)
    lastupdatedate = Column(DateTime, nullable=True)
    lastupdatedate_as_number = Column(Integer, nullable=True)

    # Relationships
    role = relationship("Role", back_populates="role_workflows")
    workflow = relationship("Workflow", back_populates="role_workflows")
