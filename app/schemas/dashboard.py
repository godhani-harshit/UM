from typing import Dict, List
from pydantic import BaseModel

class DashboardStatistics(BaseModel):
    total_cases: int
    pending_cases: int
    completed_today: int
    overdue_cases: int
    by_workflow: Dict[str, int]
    by_priority: Dict[str, int]


class WorkflowAccess(BaseModel):
    workflow_id: str
    workflow_name: str
    is_enabled: bool
    description: str
    icon: str
    button_text: str
    button_icon: str
    route: str


class DashboardWorkflowsResponse(BaseModel):
    workflows: List[WorkflowAccess]