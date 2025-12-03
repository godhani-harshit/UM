from typing import List
from sqlalchemy import text
from fastapi import HTTPException
from app.core.logging import logger
from app.core.database import get_sync_database_url
from app.schemas.dashboard import DashboardStatistics, WorkflowAccess


# ------------------------------------------------------------
# Dashboard Statistics
# ------------------------------------------------------------
async def get_dashboard_statistics() -> DashboardStatistics:
    try:
        async with get_sync_database_url() as session:

            # Total cases
            total_cases_query = text("""
                SELECT COUNT(*) 
                FROM um.um_authorizations 
                WHERE is_deleted = false
            """)
            total_cases = (await session.execute(total_cases_query)).scalar() or 0

            # Pending cases
            pending_cases_query = text("""
                SELECT COUNT(*) 
                FROM um.um_authorizations 
                WHERE is_deleted = false 
                AND status NOT IN ('completed', 'closed', 'approved', 'denied')
            """)
            pending_cases = (await session.execute(pending_cases_query)).scalar() or 0

            # Completed today
            completed_today_query = text("""
                SELECT COUNT(*) 
                FROM um.um_authorizations 
                WHERE is_deleted = false 
                AND status IN ('completed', 'closed', 'approved', 'denied')
                AND DATE(updated_at) = CURRENT_DATE
            """)
            completed_today = (await session.execute(completed_today_query)).scalar() or 0

            # Overdue cases (older than 7 days)
            overdue_cases_query = text("""
                SELECT COUNT(*) 
                FROM um.um_authorizations 
                WHERE is_deleted = false 
                AND status NOT IN ('completed', 'closed', 'approved', 'denied')
                AND created_at < CURRENT_DATE - INTERVAL '7 days'
            """)
            overdue_cases = (await session.execute(overdue_cases_query)).scalar() or 0

            # Cases by workflow
            workflow_distribution_query = text("""
                SELECT 
                    COALESCE(template_type, 'unknown') AS workflow_type,
                    COUNT(*) AS count
                FROM um.um_authorizations 
                WHERE is_deleted = false
                GROUP BY template_type
            """)
            workflow_rows = (await session.execute(workflow_distribution_query)).mappings().all()
            by_workflow = {row["workflow_type"]: row["count"] for row in workflow_rows}

            # Cases by priority
            priority_distribution_query = text("""
                SELECT 
                    COALESCE(priority, 'standard') AS priority_level,
                    COUNT(*) AS count
                FROM um.um_authorizations 
                WHERE is_deleted = false
                GROUP BY priority
            """)
            priority_rows = (await session.execute(priority_distribution_query)).mappings().all()
            by_priority = {row["priority_level"]: row["count"] for row in priority_rows}

            logger.info(
                f"📊 Dashboard stats - Total: {total_cases}, Pending: {pending_cases}, Completed Today: {completed_today}"
            )

            return DashboardStatistics(
                total_cases=total_cases,
                pending_cases=pending_cases,
                completed_today=completed_today,
                overdue_cases=overdue_cases,
                by_workflow=by_workflow,
                by_priority=by_priority
            )

    except Exception as e:
        logger.error(f"❌ Error fetching dashboard statistics: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching dashboard statistics: {str(e)}"
        )


# ------------------------------------------------------------
# Available Workflows
# ------------------------------------------------------------
async def get_available_workflows(
    user_workflows: List[str] = None,
    user_permissions: List[str] = None
) -> List[WorkflowAccess]:
    try:
        async with get_sync_database_url() as session:
            logger.info("🔍 Fetching workflows from database")
            logger.debug(f"User JWT workflows: {user_workflows}")

            workflow_query = text("""
                SELECT 
                    w.workflow_key AS workflow_id,
                    w.workflow_name,
                    w.description,
                    w.icon,
                    w.route_path,
                    w.button_text,
                    w.button_icon,
                    w.display_order
                FROM um.workflows w
                WHERE w.deleted = 'n'
                ORDER BY w.display_order, w.workflow_name
            """)

            rows = (await session.execute(workflow_query)).mappings().all()
            logger.info(f"📋 Found {len(rows)} workflows in database")

            if not rows:
                logger.warning("⚠️ No workflows found in database")
                return []

            workflows: List[WorkflowAccess] = []

            for row in rows:
                workflow_id = row["workflow_id"]
                is_enabled = workflow_id in (user_workflows or [])

                icon = row.get("icon") or "fa-folder"
                button_icon = row.get("button_icon") or "fa-arrow-right"
                route = row.get("route_path") or f"/{workflow_id}"
                button_text = row.get("button_text") or "Start"

                # Warn missing configuration
                if not row.get("icon"):
                    logger.warning(f"⚠️ Workflow '{workflow_id}' missing icon in database")
                if not row.get("route_path"):
                    logger.warning(f"⚠️ Workflow '{workflow_id}' missing route_path in database")
                if not row.get("button_text"):
                    logger.warning(f"⚠️ Workflow '{workflow_id}' missing button_text in database")
                if not row.get("button_icon"):
                    logger.warning(f"⚠️ Workflow '{workflow_id}' missing button_icon in database")

                workflows.append(
                    WorkflowAccess(
                        workflow_id=workflow_id,
                        workflow_name=row["workflow_name"],
                        is_enabled=is_enabled,
                        description=row["description"] or f"{row['workflow_name']} workflow",
                        icon=icon,
                        route=route,
                        button_text=button_text,
                        button_icon=button_icon,
                        display_order=row.get("display_order", 999)
                    )
                )

            enabled_count = sum(1 for w in workflows if w.is_enabled)
            logger.info(
                f"✅ Returning {len(workflows)} workflows ({enabled_count} enabled for user)"
            )
            logger.info(
                f"Enabled workflows: {[w.workflow_id for w in workflows if w.is_enabled]}"
            )

            return workflows

    except Exception as e:
        logger.error(f"❌ Error fetching available workflows: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching available workflows: {str(e)}"
        )