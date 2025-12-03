from app.core.logging import logger
from app.core.config import get_settings, get_database_url
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from fastapi import HTTPException, status


Base = declarative_base()


def get_sync_database_url() -> str:
    url = get_database_url()
    if url.startswith("postgresql+asyncpg"):
        return url.replace("postgresql+asyncpg", "postgresql")
    if url.startswith("postgresql://"):
        return url 
    return url


# Lazy initialization
engine = None
SessionLocal = None


def get_engine():
    global engine
    if engine is not None:
        return engine
    try:
        sync_url = get_sync_database_url()
        s = get_settings()
        engine = create_engine(
            sync_url,
            pool_size=s["DB_POOL_SIZE"],
            max_overflow=s["DB_MAX_OVERFLOW"],
            pool_timeout=s["DB_POOL_TIMEOUT"],
            pool_recycle=s["DB_POOL_RECYCLE"],
            echo=s["DB_ECHO"],
        )
        return engine
    except Exception as e:
        logger.warning(f"Database engine not initialized: {e}")
        return None


def ensure_session_factory():
    global SessionLocal
    if SessionLocal is None:
        eng = get_engine()
        if eng is None:
            return None
        SessionLocal = sessionmaker(
            autocommit=False,
            autoflush=False,
            bind=eng,
        )
    return SessionLocal


def get_db():
    factory = ensure_session_factory()
    if factory is None:
        # Provide clear API response when DB is not configured
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database is not configured. Set DATABASE_URL or PostgreSQL env vars."
        )
    db = factory()
    try:
        yield db
    finally:
        db.close()


def init_db():
    try:
        eng = get_engine()
        if eng is None:
            logger.warning("Skipping DB init: database not configured")
            return
        logger.info("🗄️ Initializing database...")
        Base.metadata.create_all(bind=eng)
        logger.info("✅ Database tables created successfully.")
    except Exception as e:
        logger.exception(f"❌ Database initialization failed: {str(e)}")
        raise


def test_connection():
    try:
        eng = get_engine()
        if eng is None:
            logger.warning("DB not configured; health check will report degraded")
            return False
        with eng.connect() as conn:
            conn.execute("SELECT 1")
        logger.info("✅ Database connection successful")
        return True
    except Exception as e:
        logger.error(f"❌ Database connection failed: {str(e)}")
        return False


if __name__ == "__main__":
    print("Testing DB connection...")
    test_connection()