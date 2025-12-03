import sys
from pathlib import Path
from app.core.config import get_settings
from loguru import logger as loguru_logger


def setup_logging():
    loguru_logger.remove()
    s = get_settings()
    
    # Console handler with colors
    loguru_logger.add(
        sys.stdout,
        format=(
            "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | "
            "<level>{level: <8}</level> | "
            "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> | "
            "<level>{message}</level>"
        ),
        level=s["LOG_LEVEL"],
        colorize=True,
        backtrace=True,
        diagnose=True
    )
    
    # File handler for production environments
    if s["ENVIRONMENT"] in ["production", "staging"]:
        log_dir = Path("logs")
        log_dir.mkdir(exist_ok=True)
        
        loguru_logger.add(
            str(log_dir / "um_api_{time:YYYY-MM-DD}.log"),
            rotation="00:00",  # Rotate at midnight
            retention="30 days",  # Keep logs for 30 days
            compression="zip",  # Compress old logs
            level="INFO",
            format=(
                "{time:YYYY-MM-DD HH:mm:ss.SSS} | "
                "{level: <8} | "
                "{name}:{function}:{line} | "
                "{message}"
            ),
            backtrace=True,
            diagnose=False  # Don't include variable values in production
        )
        
        # Separate file for errors
        loguru_logger.add(
            str(log_dir / "um_api_errors_{time:YYYY-MM-DD}.log"),
            rotation="00:00",
            retention="90 days",  # Keep error logs longer
            compression="zip",
            level="ERROR",
            format=(
                "{time:YYYY-MM-DD HH:mm:ss.SSS} | "
                "{level: <8} | "
                "{name}:{function}:{line} | "
                "{message}\n"
                "{exception}"
            ),
            backtrace=True,
            diagnose=True
        )
    
    return loguru_logger


# Initialize and export logger
logger = setup_logging()


# Convenience functions for common log patterns
def log_api_request(method: str, path: str, user_email: str = None):
    """Log API request"""
    user_info = f" | User: {user_email}" if user_email else ""
    logger.info(f"📥 {method} {path}{user_info}")


def log_api_response(method: str, path: str, status_code: int, duration_ms: float):
    """Log API response"""
    emoji = "✅" if status_code < 400 else "⚠️" if status_code < 500 else "❌"
    logger.info(f"{emoji} {method} {path} | {status_code} | {duration_ms:.2f}ms")


def log_db_query(query_type: str, table: str):
    """Log database query"""
    logger.debug(f"🗄️  {query_type} on {table}")


def log_auth_event(event: str, email: str, success: bool):
    """Log authentication event"""
    emoji = "🔓" if success else "🔒"
    status = "SUCCESS" if success else "FAILED"
    logger.info(f"{emoji} {event} | {email} | {status}")