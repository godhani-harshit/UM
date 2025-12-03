from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.services.dashboard_service import get_dashboard_statistics, get_available_workflows
from app.services.auth_service import get_current_user_from_jwt
from app.schemas.dashboard import DashboardStatistics, DashboardWorkflowsResponse
from app.core.logging import logger

router = APIRouter()


@router.get(
    "/dashboard/statistics",
    response_model=DashboardStatistics,
    summary="Get dashboard statistics",
    description="Retrieve overview statistics for the dashboard from um_authorizations table"
)
async def get_dashboard_stats(
    current_user: dict = Depends(get_current_user_from_jwt)
):
    try:
        logger.info(f" Fetching dashboard statistics for user: {current_user['email']}")
        logger.debug(f"User role: {current_user.get('role')}, workflows: {current_user.get('workflows')}")

        # Get statistics from database service
        stats = await get_dashboard_statistics()

        logger.info(f" Dashboard statistics retrieved: {stats.total_cases} total cases")
        return stats

    except Exception as e:
        logger.error(f" Failed to fetch dashboard statistics: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch dashboard statistics: {str(e)}"
        )


@router.get(
    "/dashboard/workflows",
    response_model=DashboardWorkflowsResponse,
    summary="Get available workflows",
    description="Retrieve list of available workflows with access information from database"
)
async def get_workflows(
    current_user: dict = Depends(get_current_user_from_jwt)
):
    try:
        logger.info(f" Fetching available workflows for user: {current_user['email']}")

        # Get user's workflows from JWT token (already validated and loaded from DB during login)
        user_workflows = current_user.get('workflows', [])
        user_role = current_user.get('role')
        user_permissions = current_user.get('permissions', [])

        logger.debug(f"User workflows from JWT: {user_workflows}")
        logger.debug(f"User role: {user_role}")
        logger.debug(f"User permissions: {len(user_permissions)} total")

        # Get workflows from database service
        # Pass user's authorized workflows to filter/enhance the results
        workflows = await get_available_workflows(
            user_workflows=user_workflows,
            user_permissions=user_permissions
        )

        logger.info(f" Retrieved {len(workflows)} workflows from database")
        logger.debug(f"Workflow IDs: {[w.workflow_id for w in workflows]}")

        return DashboardWorkflowsResponse(workflows=workflows)

    except Exception as e:
        logger.error(f"❌ Failed to fetch workflows: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch workflows: {str(e)}"
        )