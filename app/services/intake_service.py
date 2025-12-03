from math import ceil
from typing import Optional
from fastapi import HTTPException
from sqlalchemy import text, select
from app.core.logging import logger
from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.authorization import Authorization
from app.core.database import get_sync_database_url
from app.schemas.intake import IntakeQueueResponse, IntakeQueueItem, Pagination, Statistics


# ---------------------------------------------------------
# Functional replacement for IntakeService.get_queue_items()
# ---------------------------------------------------------
async def get_queue_items(
    page: int,
    page_size: int,
    status: Optional[str] = None,
    source: Optional[str] = None,
    health_plan: Optional[str] = None,
    template: Optional[str] = None,
    priority: Optional[str] = None,
    search: Optional[str] = None,
    sort_by: Optional[str] = None,
    sort_order: Optional[str] = None
) -> IntakeQueueResponse:
    try:
        async with get_sync_database_url() as session:

            base_query = """
                SELECT
                    source,
                    health_plan,
                    document_id,
                    template_type,
                    authorization_number AS auth_number,
                    member_name,
                    dob,
                    receipt_datetime AS received_date,
                    priority,
                    file_arrival_time AS queue_create_time,
                    status,
                    COALESCE(assigned_user, 'Unassigned') AS assigned_to
                FROM um.um_authorizations
                WHERE 1=1
            """

            filters = []
            params = {}

            if source:
                filters.append("LOWER(source) = LOWER(:source)")
                params["source"] = source

            if health_plan:
                filters.append("LOWER(health_plan) = LOWER(:health_plan)")
                params["health_plan"] = health_plan

            if template:
                filters.append("LOWER(template_type) = LOWER(:template)")
                params["template"] = template

            if status:
                filters.append("LOWER(status) = LOWER(:status)")
                params["status"] = status

            if priority:
                filters.append("LOWER(priority) = LOWER(:priority)")
                params["priority"] = priority

            if search:
                filters.append(
                    "(LOWER(authorization_number) LIKE LOWER(:search) "
                    "OR LOWER(member_name) LIKE LOWER(:search))"
                )
                params["search"] = f"%{search}%"

            if filters:
                base_query += " AND " + " AND ".join(filters)

            sort_map = {
                "received_date": "receipt_datetime",
                "priority": "priority",
                "lapse_time": "receipt_datetime"
            }

            sort_field = sort_map.get(sort_by, "receipt_datetime")
            sort_direction = "DESC" if (sort_order and sort_order.lower() == "desc") else "ASC"

            base_query += f" ORDER BY {sort_field} {sort_direction}"

            main_query = base_query + " LIMIT :limit OFFSET :offset"
            params["limit"] = page_size
            params["offset"] = (page - 1) * page_size

            logger.debug(f"Executing query: {main_query} with params: {params}")
            result = await session.execute(text(main_query), params)
            records = result.mappings().all()

            queue_items = []
            for row in records:
                queue_items.append(
                    IntakeQueueItem(
                        source=row.get("source") or "N/A",
                        health_plan=row.get("health_plan") or "N/A",
                        document_id=row.get("document_id") or "N/A",
                        auth_number=row.get("auth_number") or "N/A",
                        template=row.get("template_type") or "N/A",
                        member_name=row.get("member_name") or "Unknown",
                        dob=row.get("dob"),
                        received_date=row.get("received_date"),
                        queue_time=row.get("queue_create_time"),
                        priority=row.get("priority") or "Standard",
                        lapse_time=calculate_lapse_time(row.get("received_date")),
                        status=row.get("status") or "Unknown",
                        assigned_to=row.get("assigned_to") or "Unassigned"
                    )
                )

            total_cases = (await session.execute(
                text("SELECT COUNT(*) FROM um.um_authorizations WHERE is_deleted=false")
            )).scalar()

            expedited_cases = (await session.execute(
                text("SELECT COUNT(*) FROM um.um_authorizations WHERE is_deleted=false AND priority='Expedited'")
            )).scalar()

            available_cases = (await session.execute(
                text("SELECT COUNT(*) FROM um.um_authorizations WHERE is_deleted=false AND status='Queued'")
            )).scalar()

            count_query = "SELECT COUNT(*) FROM um.um_authorizations WHERE 1=1"
            count_params = {}
            count_filters = filters

            if count_filters:
                count_query += " AND " + " AND ".join(count_filters)
                count_params = params

            count_result = await session.execute(text(count_query), count_params)
            total_items = count_result.scalar() or 0

            total_pages = ceil(total_items / page_size) if page_size else 0
            pagination = Pagination(
                page=page,
                page_size=page_size,
                total_pages=total_pages,
                has_next=page < total_pages,
                has_previous=page > 1,
            )

            stats = Statistics(
                total_cases=total_cases,
                available_cases=available_cases,
                expedited_cases=expedited_cases,
            )

            logger.info(f"Fetched {len(queue_items)} cases (page {page}/{total_pages})")

            return IntakeQueueResponse(cases=queue_items, pagination=pagination, statistics=stats)

    except Exception as e:
        logger.error(f"Database error while fetching queue items: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


# ---------------------------------------------------------
# Functional version of lapse time calculator
# ---------------------------------------------------------
def calculate_lapse_time(start_time: datetime, end_time: datetime | None = None) -> str:
    if not start_time:
        return "N/A"

    if start_time.tzinfo is None:
        start_time = start_time.replace(tzinfo=timezone.utc)

    end_time = end_time or datetime.now(timezone.utc)
    if end_time.tzinfo is None:
        end_time = end_time.replace(tzinfo=timezone.utc)

    delta = end_time - start_time
    total_hours = int(delta.total_seconds() // 3600)

    days = abs(total_hours) // 24
    hours = abs(total_hours) % 24
    prefix = "-" if total_hours < 0 else ""

    return f"{prefix}{days} days {hours} hours"


# ---------------------------------------------------------
# Functional version of get_document_data
# ---------------------------------------------------------
async def get_document_data(document_id: str) -> dict:
    try:
        async with get_sync_database_url() as session:
            query = text("""
                SELECT form_data
                FROM um.um_authorizations
                WHERE document_id = :document_id
            """)

            result = await session.execute(query, {"document_id": document_id})
            row = result.mappings().first()

            if not row or not row["form_data"]:
                raise HTTPException(status_code=404, detail="Document not found or empty")

            return row["form_data"]

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving document data: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# ---------------------------------------------------------
# Functional version of update_document_data
# ---------------------------------------------------------
async def update_document_data(document_id: str, updated_data: dict) -> dict:
    try:
        async with get_sync_database_url() as session:
            query = text("""
                SELECT form_data
                FROM um.um_authorizations
                WHERE document_id = :document_id
            """)

            result = await session.execute(query, {"document_id": document_id})
            row = result.mappings().first()

            if not row or not row["form_data"]:
                raise HTTPException(status_code=404, detail="Document not found")

            form_data = row["form_data"]

            def update_user_values(existing, updates):
                for key, value in updates.items():
                    if isinstance(value, dict) and key in existing:
                        if set(value.keys()) == {"userPopulated"}:
                            existing[key]["userPopulated"] = value["userPopulated"]
                        else:
                            update_user_values(existing[key], value)
                    elif key in existing and isinstance(existing[key], dict):
                        if "userPopulated" in existing[key] and not isinstance(value, dict):
                            existing[key]["userPopulated"] = value
                return existing

            updated_form_data = update_user_values(form_data, updated_data)

            update_query = text("""
                UPDATE um.um_authorizations
                SET form_data = :form_data, status = 'in_progress'
                WHERE document_id = :document_id
            """)

            await session.execute(update_query, {
                "form_data": updated_form_data,
                "document_id": document_id
            })
            await session.commit()

            return {"message": "Document updated successfully", "document_id": document_id}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating document: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# ---------------------------------------------------------
# Functional version of get_intake_case_by_document_id
# ---------------------------------------------------------
async def get_intake_case_by_document_id(document_id: str, session: AsyncSession) -> Optional[Authorization]:
    try:
        query = select(Authorization).where(Authorization.document_id == document_id)
        result = await session.execute(query)
        return result.scalar_one_or_none()
    except Exception as e:
        logger.error(f"Error fetching intake case: {str(e)}")
        raise