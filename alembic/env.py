import asyncio
from sqlalchemy import pool
from alembic import context
from app.core.database import Base  
from logging.config import fileConfig
from sqlalchemy.ext.asyncio import async_engine_from_config

# Import only SQLAlchemy models ONCE
from app.models.user import User
from app.models.role import Role
from app.models.user_roles import UserRoleLink
from app.models.activity_log import ActivityLog
from app.models.authorization import Authorization
from app.models.oauth import OAuthProvider, OAuthToken
from app.models.permission import Permission
from app.models.module import Module
from app.models.references import UMConfig, HealthPlan, DiagnosisCode, ProcedureCode, Template, Provider
from app.models.role_permissions import RolePermission
from app.models.role_workflows import RoleWorkflow
from app.models.session import UserSession
from app.models.workflow import Workflow

# Alembic config object
config = context.config

# Logging setup
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Target metadata for 'autogenerate'
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()

def do_run_migrations(connection):
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        include_schemas=True
    )

    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    """In this scenario we need to create an Engine
    and associate a connection with the context.

    """

    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""

    asyncio.run(run_async_migrations())

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()