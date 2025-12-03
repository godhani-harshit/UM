import json
from pathlib import Path
from decimal import Decimal
from datetime import datetime
from typing import Dict, Optional
from app.core.logging import logger
from app.models.activity_log import ActivityLog
from app.core.database import get_sync_database_url


async def log_auth_event(
    user_id: Optional[str],
    action: str,
    success: bool,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
    details: Optional[Dict] = None
):
    try:
        details_text = str(details) if details else None
        timestamp_num = int(datetime.utcnow().strftime('%Y%m%d%H%M%S'))

        async with get_sync_database_url() as session:
            log_entry = ActivityLog(
                user_id=user_id,
                action=action,
                entity="auth",
                details=details_text,
                ip_address=ip_address,
                user_agent=user_agent,
                createddate_as_number=Decimal(timestamp_num),
                lastupdatedate_as_number=Decimal(timestamp_num)
            )
            session.add(log_entry)
            await session.commit()

            level = "INFO" if success else "WARNING"
            logger.log(
                level,
                f"🔐 COMPLIANCE LOG | Action: {action} | User: {user_id} | "
                f"Success: {success} | IP: {ip_address}"
            )

    except Exception as e:
        logger.error(f"Failed to log auth event: {str(e)}")
        await fallback_log(action, user_id, success, ip_address, details)


async def log_security_event(
    event_type: str,
    severity: str = "MEDIUM",
    ip_address: Optional[str] = None,
    user_id: Optional[str] = None,
    details: Optional[Dict] = None
):
    await log_auth_event(
        user_id=user_id,
        action=f"SECURITY_{event_type}",
        success=False,
        ip_address=ip_address,
        details=details
    )


async def log_login_success(
    user_id: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
    roles: list = None,
    workflows: list = None
):
    details = {
        "roles": roles or [],
        "workflows": workflows or [],
        "event": "login_success"
    }

    await log_auth_event(
        user_id=user_id,
        action="LOGIN_SUCCESS",
        success=True,
        ip_address=ip_address,
        user_agent=user_agent,
        details=details
    )


async def log_login_failed(
    email: str,
    reason: str,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None
):
    details = {
        "email": email,
        "reason": reason,
        "event": "login_failed"
    }

    await log_auth_event(
        user_id=None,
        action="LOGIN_FAILED",
        success=False,
        ip_address=ip_address,
        user_agent=user_agent,
        details=details
    )


async def fallback_log(
    action: str,
    user_id: Optional[str],
    success: bool,
    ip_address: Optional[str],
    details: Optional[Dict]
):
    try:
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "action": action,
            "user_id": user_id,
            "success": success,
            "ip_address": ip_address,
            "details": details
        }

        log_dir = Path("logs/compliance")
        log_dir.mkdir(parents=True, exist_ok=True)

        log_file = log_dir / "auth_events_fallback.json"

        with open(log_file, "a") as f:
            f.write(json.dumps(log_data) + "\n")

    except Exception as fallback_error:
        logger.error(f"Fallback logging also failed: {fallback_error}")