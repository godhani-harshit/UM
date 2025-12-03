from sqlalchemy import text
from app.core.logging import logger
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession


# -------------------------------
# Acquire Lock
# -------------------------------
async def acquire_lock(
    session: AsyncSession,
    document_id: str,
    user_email: str,
    is_admin: bool = False,
    force: bool = False
) -> dict:
    """
    Acquire lock for a document
    """
    try:
        # Clean expired locks globally
        await cleanup_expired_locks(session)

        # Check existing lock
        check_query = text("""
            SELECT cl.assigned_user, cl.lock_expires, cl.lock_issued
            FROM um.um_case_lock cl
            WHERE cl.document_id = :document_id 
            AND cl.deleted = 'n'
        """)
        
        result = await session.execute(check_query, {"document_id": document_id})
        existing_lock = result.fetchone()

        if existing_lock:
            lock_owner = existing_lock.assigned_user
            lock_expires = existing_lock.lock_expires
            lock_issued = existing_lock.lock_issued

            current_time = datetime.utcnow()
            time_diff_minutes = (current_time - lock_issued).total_seconds() / 60
            is_expired = lock_expires <= current_time or time_diff_minutes > 30

            logger.info(
                f"📋 Lock check - Owner: {lock_owner}, Current User: {user_email}, "
                f"Expired: {is_expired}, Time Diff: {time_diff_minutes:.1f} min"
            )

            # User already owns the lock
            if lock_owner == user_email:
                if is_expired:
                    logger.info(f"🔄 Lock expired for {user_email} on {document_id}, deleting old lock")
                    await _delete_lock(session, document_id)
                else:
                    logger.info(f"♻️ Lock still valid for {user_email} on {document_id}, refreshing")
                    return await refresh_lock(session, document_id, user_email)

            # Another user owns the lock
            else:
                if force and is_admin:
                    logger.info(f"🛠️ Admin {user_email} forcing lock override from {lock_owner} on {document_id}")
                    await _delete_lock(session, document_id)
                else:
                    return {
                        "success": False,
                        "message": f"Document is currently locked by {lock_owner}. "
                                   f"Lock expires at {lock_expires}",
                        "lock_owner": lock_owner,
                        "lock_expires": lock_expires.isoformat()
                    }

        # Insert new lock
        lock_expires = datetime.utcnow() + timedelta(minutes=30)
        insert_query = text("""
            INSERT INTO um.um_case_lock 
            (document_id, assigned_user, lock_issued, lock_expires, deleted, lastupdatedate)
            VALUES (:document_id, :assigned_user, CURRENT_TIMESTAMP, :lock_expires, 'n', CURRENT_TIMESTAMP)
            ON CONFLICT (document_id)
            DO UPDATE SET
                assigned_user = EXCLUDED.assigned_user,
                lock_issued = CURRENT_TIMESTAMP,
                lock_expires = EXCLUDED.lock_expires,
                deleted = 'n',
                lastupdatedate = CURRENT_TIMESTAMP
        """)

        await session.execute(insert_query, {
            "document_id": document_id,
            "assigned_user": user_email,
            "lock_expires": lock_expires
        })
        await session.commit()

        logger.info(f"🔒 Lock acquired by {user_email} on {document_id}, expires at {lock_expires}")

        return {
            "success": True,
            "message": "Lock acquired successfully",
            "lock_owner": user_email,
            "lock_expires": lock_expires.isoformat()
        }

    except Exception as e:
        await session.rollback()
        logger.error(f"❌ Failed to acquire lock: {str(e)}")
        raise


# -------------------------------
# Internal Delete Lock
# -------------------------------
async def _delete_lock(session: AsyncSession, document_id: str) -> bool:
    """
    Hard delete lock for a document
    """
    try:
        query = text("""
            UPDATE um.um_case_lock
            SET deleted = 'y',
                lastupdatedate = CURRENT_TIMESTAMP
            WHERE document_id = :document_id
            AND deleted = 'n'
        """)

        result = await session.execute(query, {"document_id": document_id})
        await session.commit()

        if result.rowcount > 0:
            logger.info(f"🗑️ Lock deleted for {document_id}")
            return True

        return False

    except Exception as e:
        await session.rollback()
        logger.error(f"❌ Failed to delete lock: {str(e)}")
        raise


# -------------------------------
# Release Lock
# -------------------------------
async def release_lock(
    session: AsyncSession,
    document_id: str,
    user_email: str,
    force: bool = False
) -> bool:
    """
    Release lock for a document
    """
    try:
        query = text("""
            UPDATE um.um_case_lock 
            SET deleted = 'y',
                lastupdatedate = CURRENT_TIMESTAMP
            WHERE document_id = :document_id
            AND deleted = 'n'
            AND (assigned_user = :user_email OR :force = true)
        """)

        result = await session.execute(query, {
            "document_id": document_id,
            "user_email": user_email,
            "force": force
        })
        await session.commit()

        if result.rowcount > 0:
            logger.info(f"🔓 Lock released on {document_id} by {user_email} (force={force})")
            return True

        logger.warning(f"⚠️ No lock found or permission denied for {document_id}")
        return False

    except Exception as e:
        await session.rollback()
        logger.error(f"❌ Failed to release lock: {str(e)}")
        raise


# -------------------------------
# Refresh Lock
# -------------------------------
async def refresh_lock(
    session: AsyncSession,
    document_id: str,
    user_email: str
) -> dict:
    """
    Refresh lock expiration
    """
    try:
        new_exp = datetime.utcnow() + timedelta(minutes=30)

        query = text("""
            UPDATE um.um_case_lock
            SET lock_expires = :lock_expires,
                lock_issued = CURRENT_TIMESTAMP,
                lastupdatedate = CURRENT_TIMESTAMP
            WHERE document_id = :document_id
            AND assigned_user = :user_email
            AND deleted = 'n'
        """)

        result = await session.execute(query, {
            "document_id": document_id,
            "user_email": user_email,
            "lock_expires": new_exp
        })
        await session.commit()

        if result.rowcount > 0:
            logger.info(f"🔄 Lock refreshed by {user_email} on {document_id}")
            return {
                "success": True,
                "message": "Lock refreshed successfully",
                "lock_owner": user_email,
                "lock_expires": new_exp.isoformat()
            }

        return {"success": False, "message": "Failed to refresh lock"}

    except Exception as e:
        await session.rollback()
        logger.error(f"❌ Failed to refresh lock: {str(e)}")
        raise


# -------------------------------
# Cleanup Expired Locks
# -------------------------------
async def cleanup_expired_locks(session: AsyncSession) -> int:
    """
    Clean up expired locks
    """
    try:
        query = text("""
            UPDATE um.um_case_lock
            SET deleted = 'y',
                lastupdatedate = CURRENT_TIMESTAMP
            WHERE lock_expires <= CURRENT_TIMESTAMP
            AND deleted = 'n'
        """)

        result = await session.execute(query)
        await session.commit()

        count = result.rowcount
        if count > 0:
            logger.info(f"🧹 Cleaned up {count} expired locks")

        return count

    except Exception as e:
        await session.rollback()
        logger.error(f"❌ Failed to cleanup expired locks: {str(e)}")
        raise


# -------------------------------
# Get Lock Status
# -------------------------------
async def get_lock_status(session: AsyncSession, document_id: str) -> dict:
    """
    Get current lock status for a document
    """
    try:
        query = text("""
            SELECT assigned_user, lock_issued, lock_expires
            FROM um.um_case_lock
            WHERE document_id = :document_id
            AND deleted = 'n'
        """)

        result = await session.execute(query, {"document_id": document_id})
        lock = result.fetchone()

        if lock:
            now = datetime.utcnow()
            is_expired = lock.lock_expires <= now

            if is_expired:
                logger.info(f"📋 Lock for {document_id} is expired, returning unlocked")
                return {
                    "is_locked": False,
                    "assigned_user": None,
                    "lock_issued": None,
                    "lock_expires": None
                }

            return {
                "is_locked": True,
                "assigned_user": lock.assigned_user,
                "lock_issued": lock.lock_issued.isoformat(),
                "lock_expires": lock.lock_expires.isoformat()
            }

        return {
            "is_locked": False,
            "assigned_user": None,
            "lock_issued": None,
            "lock_expires": None
        }

    except Exception as e:
        logger.error(f"❌ Failed to get lock status: {str(e)}")
        raise