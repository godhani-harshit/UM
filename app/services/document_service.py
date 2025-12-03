from typing import Optional
from sqlalchemy import text
from datetime import datetime, date, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.authorization import Authorization


async def create_authorization_record(
    session: AsyncSession,
    file_name: str,
    file_url: str,
    file_size: int,
    file_arrival_time: Optional[datetime],
    source: str = "Upload"
) -> Authorization:

    # Default to current UTC time if none is provided
    if file_arrival_time is None:
        file_arrival_time = datetime.utcnow()

    # Normalize to naive UTC datetime
    if file_arrival_time.tzinfo is not None:
        file_arrival_time = (
            file_arrival_time
            .astimezone(timezone.utc)
            .replace(tzinfo=None)
        )

    # Create database record
    record = Authorization(
        file_name=file_name,
        file_url=file_url,
        file_size=file_size,

        # Initial state
        status="Queued",

        # Default stub values
        member_name="Unassigned",
        dob=date(1900, 1, 1),
        healthplan_id="UNKNOWN",
        health_plan="UNKNOWN",
        requesting_npi="UNKNOWN",
        requesting_name="UNKNOWN",
        template_type="Undetermined",
        priority="Undetermined",

        # Track source
        source=source,

        # When the system received the file
        receipt_datetime=file_arrival_time
    )

    session.add(record)
    await session.commit()
    await session.refresh(record)
    return record


async def check_file_exists(session: AsyncSession, file_name: str) -> bool:
    query = text("""
        SELECT COUNT(*) AS count
        FROM um.um_authorizations
        WHERE file_name = :file_name
    """)

    result = await session.execute(query, {"file_name": file_name})
    count = result.scalar()

    return count > 0