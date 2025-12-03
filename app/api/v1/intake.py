from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import APIRouter, Depends, HTTPException, Query, Body
from typing import Optional
from app.core.database import get_db
from app.services.intake_service import (
    get_queue_items,
    get_intake_case_by_document_id,
    update_document_data,
)
from app.services.auth_service import get_current_user_from_jwt
from app.schemas.intake import IntakeCaseCreate, IntakeCaseResponse, IntakeQueueResponse, IntakeCaseDetailResponse
from app.services.document_service import create_authorization_record
from app.core.logging import logger

router = APIRouter()

@router.post(
    "/intake/cases",
    response_model=IntakeCaseResponse,
    summary="Create intake case from uploaded file",
    description="Create authorization record for a file that's already uploaded to blob storage"
)
async def create_intake_case_from_upload(
    case_data: IntakeCaseCreate,
    session: AsyncSession = Depends(get_db)
):
    """
    Create an intake case (authorization record) for a file that's already in blob storage.
    
    This endpoint is typically called by Function App via Service Bus after file upload.
    
    Args:
        case_data (IntakeCaseCreate): Intake case creation data including file details
        
    Returns:
        IntakeCaseResponse: Created intake case details
        
    Raises:
        HTTPException: 500 error if case creation fails
    """
    try:
        logger.info(f"📝 Creating intake case for file: {case_data.file_name}")

        # Call the service to create the authorization record
        record = await create_authorization_record(
            session=session,
            file_name=case_data.file_name,
            file_url=case_data.file_url,
            file_size=case_data.file_size,
            file_arrival_time=case_data.file_arrival_time or datetime.utcnow(),
            source=case_data.source or "Upload"
        )

        logger.info(f"✅ Intake case created: {record.id}")

        # Construct response
        return IntakeCaseResponse(
            authorization_id=record.id,
            document_id=record.file_name.replace(".", "-") + "-doc",
            file_name=record.file_name,
            file_url=record.file_url,
            file_size=record.file_size,
            file_arrival_time=record.file_arrival_time,
            status=record.status,
            source=record.source,
            member_name=record.member_name,
            health_plan=record.health_plan,
            priority=record.priority,
            message="Intake case created successfully"
        )

    except Exception as e:
        logger.error(f"❌ Intake case creation failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Intake case creation failed: {str(e)}"
        )

@router.get(
    "/intake/queue",
    response_model=IntakeQueueResponse,
    summary="Get intake queue",
    description="Retrieve list of cases in intake processing queue"
)
async def get_intake_queue(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(10, ge=1, le=100, description="Number of items per page"),
    status: Optional[str] = Query(None, description="Filter by status: new, in_progress, completed, unable_to_process"),
    source: Optional[str] = Query(None, description="Filter by source"),
    health_plan: Optional[str] = Query(None, description="Filter by health plan"),
    template: Optional[str] = Query(None, description="Filter by template"),
    priority: Optional[str] = Query(None, description="Filter by priority: expedited, standard"),
    search: Optional[str] = Query(None, description="Search by auth number or member name"),
    sort_by: Optional[str] = Query("received_date", description="Sort by: received_date, priority, lapse_time"),
    sort_order: Optional[str] = Query("desc", description="Sort order: asc, desc"),
    current_user: dict = Depends(get_current_user_from_jwt)
):
    """
    Get intake processing queue with filtering, sorting, and pagination.
    
    Args:
        page (int): Page number for pagination (default: 1)
        page_size (int): Number of items per page (default: 10, max: 100)
        status (str, optional): Filter by case status
        source (str, optional): Filter by document source
        health_plan (str, optional): Filter by health plan
        template (str, optional): Filter by template type
        priority (str, optional): Filter by priority level
        search (str, optional): Search in authorization number or member name
        sort_by (str, optional): Field to sort by
        sort_order (str, optional): Sort direction
        current_user (dict): Authenticated user information from JWT token
        
    Returns:
        IntakeQueueResponse: Paginated queue items with metadata
        
    Raises:
        HTTPException: 400 error for invalid parameters, 500 for server errors
    """
    try:
        user_email = current_user.get('email', 'unknown')
        logger.info(f"📋 Fetching intake queue - Page: {page}, PageSize: {page_size}, User: {user_email}")
    
        # Validate enum values to ensure data integrity
        if status and status not in ["new", "in_progress", "completed", "unable_to_process"]:
            raise HTTPException(
                status_code=400,
                detail="Invalid status. Must be: new, in_progress, completed, unable_to_process"
            )
        
        if priority and priority not in ["expedited", "standard"]:
            raise HTTPException(
                status_code=400,
                detail="Invalid priority. Must be: expedited, standard"
            )
        
        if sort_by and sort_by not in ["received_date", "priority", "lapse_time"]:
            raise HTTPException(
                status_code=400,
                detail="Invalid sort_by. Must be: received_date, priority, lapse_time"
            )
        
        if sort_order and sort_order not in ["asc", "desc"]:
            raise HTTPException(
                status_code=400,
                detail="Invalid sort_order. Must be: asc, desc"
            )

        # Fetch queue items from service layer
        queue_response = await get_queue_items(
            page=page,
            page_size=page_size,
            status=status,
            source=source,
            health_plan=health_plan,
            template=template,
            priority=priority,
            search=search,
            sort_by=sort_by,
            sort_order=sort_order
        )
    
        logger.info(f"✅ Intake queue fetched successfully - Total items: {queue_response.statistics.total_cases}, User: {user_email}")
        return queue_response

    except HTTPException:
        # Re-raise HTTP exceptions to maintain error response format
        raise
    except Exception as e:
        user_email = current_user.get('email', 'unknown')
        logger.error(f"❌ Failed to fetch intake queue by user {user_email}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch intake queue: {str(e)}"
        )

@router.get(
    "/intake/health",
    summary="Intake module health check",
    description="Check if intake module is operational"
)
async def intake_health_check():
    """
    Health check endpoint for intake module.
    """
    return {
        "status": "ok",
        "module": "intake",
        "features": {
            "queue_management": True,
            "case_creation": True,
            "document_processing": True
        }
    }

@router.get("/intake/cases/{document_id}", response_model=IntakeCaseDetailResponse)
async def get_intake_case_by_document_id(
    document_id: str,
    session: AsyncSession = Depends(get_db)
):
    """
    Get intake case details and document by document_id
    """
    try:
        logger.info(f"📋 Fetching intake case for document: {document_id}")
        
        # Use service layer instead of raw SQL
        record = await get_intake_case_by_document_id(
            document_id=document_id,
            session=session
        )
        
        if not record:
            raise HTTPException(status_code=404, detail="Intake case not found")
        
        # Debug: Print what's actually being returned
        print("=== DEBUG RAW RECORD ===")
        print(f"Record type: {type(record)}")
        print(f"Record attributes: {dir(record)}")
        print(f"Record dict: {record.__dict__}")
        
        # Convert to dict to see all fields
        record_dict = {key: getattr(record, key) for key in record.__mapper__.attrs.keys()}
        print(f"All fields: {record_dict}")
        
        logger.info(f"✅ Intake case fetched successfully: {document_id}")
        return record_dict  # Pydantic will automatically convert ORM model to response schema

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Failed to fetch intake case {document_id}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch intake case: {str(e)}"
        )

@router.put(
    "/Intake/cases/{document_id}/update",tags=["Intake"],
    summary="Update userPopulated fields",
)
async def update_document_user_fields(
    document_id: str,
    updated_data: dict = Body(...)
):
    result = await update_document_data(document_id, updated_data)
    return result
