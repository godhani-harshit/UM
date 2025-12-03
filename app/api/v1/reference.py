from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.services.reference_service import (
    get_reference_config_data,  # Changed from get_all_reference_data
    get_health_plans,           # New function
    get_templates,              # New function
    search_providers, 
    search_diagnosis_codes, 
    search_procedure_codes,
    search_templates,            # New function
    get_validation_config
)
from app.core.logging import logger

router = APIRouter()

@router.get("/reference/data", summary="Get reference configuration data")
async def get_reference_data(
    session: AsyncSession = Depends(get_db)
):
    """
    Get reference configuration data from um_config table only.
    
    Returns: sources, priorities, statuses
    """
    try:
        reference_data = await get_reference_config_data(session)  # Updated function call
        return reference_data
    except Exception as e:
        logger.error(f"Failed to get reference data: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve reference data")

@router.get("/reference/health-plans", summary="Get all health plans")
async def get_health_plans_endpoint(
    session: AsyncSession = Depends(get_db)
):
    """
    Get all active health plans.
    """
    try:
        health_plans = await get_health_plans(session)  # New endpoint
        return {"health_plans": health_plans}
    except Exception as e:
        logger.error(f"Failed to get health plans: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve health plans")

@router.get("/reference/templates", summary="Get or search templates")
async def get_templates_endpoint(
    search: str = Query(None, description="Search by template name or description"),
    template_type: str = Query(None, description="Filter by template type"),
    limit: int = Query(50, description="Maximum number of results"),
    session: AsyncSession = Depends(get_db)
):
    """
    Get or search templates by name, description, or type.
    """
    try:
        if search or template_type:
            templates = await search_templates(session, search, template_type, limit)
        else:
            templates = await get_templates(session)
        return {"templates": templates}
    except Exception as e:
        logger.error(f"Failed to get templates: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve templates")

@router.get("/reference/providers", summary="Search providers")
async def search_providers_endpoint(
    search: str = Query(None, description="Search by provider name or NPI"),
    limit: int = Query(50, description="Maximum number of results"),
    session: AsyncSession = Depends(get_db)
):
    """
    Search providers by name or NPI.
    """
    try:
        providers = await search_providers(session, search, limit)
        return {"providers": providers}
    except Exception as e:
        logger.error(f"Failed to search providers: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to search providers")

@router.get("/reference/diagnosis-codes", summary="Search diagnosis codes")
async def search_diagnosis_codes_endpoint(
    search: str = Query(None, description="Search by code or description"),
    limit: int = Query(50, description="Maximum number of results"),
    session: AsyncSession = Depends(get_db)
):
    """
    Search diagnosis codes by ICD-10 code or description.
    """
    try:
        codes = await search_diagnosis_codes(session, search, limit)
        return {"diagnosis_codes": codes}
    except Exception as e:
        logger.error(f"Failed to search diagnosis codes: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to search diagnosis codes")

@router.get("/reference/procedure-codes", summary="Search procedure codes")
async def search_procedure_codes_endpoint(
    search: str = Query(None, description="Search by code or description"),
    code_type: str = Query(None, description="Filter by code type: CPT or REV"),
    limit: int = Query(50, description="Maximum number of results"),
    session: AsyncSession = Depends(get_db)
):
    """
    Search procedure codes (CPT/REV) by code or description.
    """
    try:
        codes = await search_procedure_codes(session, search, code_type, limit)
        return {"procedure_codes": codes}
    except Exception as e:
        logger.error(f"Failed to search procedure codes: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to search procedure codes")

@router.get("/reference/validation-config", summary="Get validation configuration")
async def get_validation_config_endpoint(
    session: AsyncSession = Depends(get_db)
):
    """
    Get validation configuration from um_config table.
    
    Returns field validation rules including maxLength, required, patterns, etc.
    """
    try:
        validation_config = await get_validation_config(session)
        return validation_config
    except Exception as e:
        logger.error(f"Failed to get validation config: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve validation configuration")