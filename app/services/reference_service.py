import json
from app.core.logging import logger
from sqlalchemy.future import select
from typing import List, Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.references import (
    HealthPlan,
    Provider,
    DiagnosisCode,
    ProcedureCode,
    Template,
    UMConfig
)
from app.schemas.references import (
    HealthPlanResponse,
    ProviderResponse,
    DiagnosisCodeResponse,
    ProcedureCodeResponse,
    TemplateResponse
)


# ------------------------------------------------------------
# CONFIG LOADING
# ------------------------------------------------------------

async def get_reference_config_data(session: AsyncSession) -> Dict[str, Any]:
    """
    Generic loader for reference configuration values from um_config table.
    Returns dict of config name -> [{value, label}]
    """

    async def load_config_items(config_key: str) -> List[Dict[str, str]]:
        cfg = await get_config_value(session, config_key)
        if not cfg or not isinstance(cfg.config_value, list):
            return []

        return [
            {
                "value": item.get("value", ""),
                "label": item.get("display_text", "")
            }
            for item in cfg.config_value
        ]

    CONFIG_KEYS = {
        "source": "sources",
        "priority": "priorities",
        "status": "statuses",
        "intake_processing_result": "intake_processing_results",
    }

    return {
        output_key: await load_config_items(input_key)
        for input_key, output_key in CONFIG_KEYS.items()
    }


# ------------------------------------------------------------
# BASIC REFERENCES
# ------------------------------------------------------------

async def get_health_plans(session: AsyncSession) -> List[HealthPlanResponse]:
    result = await session.execute(
        select(HealthPlan)
        .filter(HealthPlan.is_active == True, HealthPlan.deleted == 'n')
        .order_by(HealthPlan.organization_marketing_name)
    )
    return [HealthPlanResponse.model_validate(hp) for hp in result.scalars().all()]


async def get_providers(session: AsyncSession) -> List[ProviderResponse]:
    result = await session.execute(
        select(Provider).filter(
            Provider.is_active == True,
            Provider.deleted == 'n'
        )
    )
    return [ProviderResponse.model_validate(obj) for obj in result.scalars().all()]


async def get_diagnosis_codes(session: AsyncSession) -> List[DiagnosisCodeResponse]:
    result = await session.execute(
        select(DiagnosisCode).filter(
            DiagnosisCode.is_active == True,
            DiagnosisCode.deleted == 'n'
        )
    )
    return [DiagnosisCodeResponse.model_validate(obj) for obj in result.scalars().all()]


async def get_procedure_codes(session: AsyncSession) -> List[ProcedureCodeResponse]:
    result = await session.execute(
        select(ProcedureCode).filter(
            ProcedureCode.is_active == True,
            ProcedureCode.deleted == 'n'
        )
    )
    return [ProcedureCodeResponse.model_validate(obj) for obj in result.scalars().all()]


async def get_templates(session: AsyncSession) -> List[TemplateResponse]:
    result = await session.execute(
        select(Template)
        .filter(Template.is_active == True, Template.deleted == 'n')
        .order_by(Template.template_name)
    )
    return [TemplateResponse.model_validate(obj) for obj in result.scalars().all()]


# ------------------------------------------------------------
# CONFIG VALUE LOOKUP
# ------------------------------------------------------------

async def get_config_value(session: AsyncSession, config_key: str) -> Optional[UMConfig]:
    stmt = (
        select(UMConfig)
        .where(
            UMConfig.config_key == config_key,
            UMConfig.is_active == True,
            UMConfig.deleted == 'n'
        )
    )
    result = await session.execute(stmt)
    return result.scalar_one_or_none()


# ------------------------------------------------------------
# SEARCH METHODS
# ------------------------------------------------------------

async def search_providers(session: AsyncSession, search_term: str = None, limit: int = 50) -> List[ProviderResponse]:
    stmt = select(Provider).filter(Provider.is_active == True, Provider.deleted == 'n')

    if search_term:
        stmt = stmt.where(
            Provider.full_name.ilike(f"%{search_term}%") |
            Provider.npi.ilike(f"%{search_term}%")
        )

    stmt = stmt.limit(limit)
    result = await session.execute(stmt)
    return [ProviderResponse.model_validate(p) for p in result.scalars().all()]


async def search_diagnosis_codes(session: AsyncSession, search_term: str = None, limit: int = 50) -> List[DiagnosisCodeResponse]:
    stmt = select(DiagnosisCode).filter(DiagnosisCode.is_active == True, DiagnosisCode.deleted == 'n')

    if search_term:
        stmt = stmt.where(
            DiagnosisCode.code_id.ilike(f"%{search_term}%") |
            DiagnosisCode.description.ilike(f"%{search_term}%") |
            DiagnosisCode.long_description.ilike(f"%{search_term}%")
        )

    stmt = stmt.limit(limit)
    result = await session.execute(stmt)
    return [DiagnosisCodeResponse.model_validate(c) for c in result.scalars().all()]


async def search_procedure_codes(session: AsyncSession, search_term: str = None, code_type: str = None, limit: int = 50) -> List[ProcedureCodeResponse]:
    stmt = select(ProcedureCode).filter(ProcedureCode.is_active == True, ProcedureCode.deleted == 'n')

    if search_term:
        stmt = stmt.where(
            ProcedureCode.code_id.ilike(f"%{search_term}%") |
            ProcedureCode.description.ilike(f"%{search_term}%") |
            ProcedureCode.long_description.ilike(f"%{search_term}%")
        )

    if code_type:
        stmt = stmt.where(ProcedureCode.code_type == code_type.upper())

    stmt = stmt.limit(limit)
    result = await session.execute(stmt)
    return [ProcedureCodeResponse.model_validate(c) for c in result.scalars().all()]


async def search_templates(session: AsyncSession, search_term: str = None, template_type: str = None, limit: int = 50) -> List[TemplateResponse]:
    stmt = select(Template).filter(Template.is_active == True, Template.deleted == 'n')

    if search_term:
        stmt = stmt.where(
            Template.template_name.ilike(f"%{search_term}%") |
            Template.description.ilike(f"%{search_term}%")
        )

    if template_type:
        stmt = stmt.where(Template.template_type == template_type)

    stmt = stmt.order_by(Template.template_name).limit(limit)
    result = await session.execute(stmt)
    return [TemplateResponse.model_validate(t) for t in result.scalars().all()]


# ------------------------------------------------------------
# VALIDATION CONFIG
# ------------------------------------------------------------

async def get_validation_config(session: AsyncSession) -> dict:
    try:
        stmt = select(UMConfig).where(
            UMConfig.config_key == "ai_input_field_json",
            UMConfig.is_active == True,
            UMConfig.deleted == 'n',
        )
        result = await session.execute(stmt)
        row = result.scalar_one_or_none()

        if not row or not row.config_value:
            logger.warning("Validation config not found, returning empty config")
            return {}

        data = row.config_value

        if isinstance(data, str):
            data = json.loads(data)

        if not isinstance(data, dict):
            logger.warning(f"Unexpected config_value type: {type(data)}")
            return {}

        return transform_validation_config(data)

    except Exception as e:
        logger.error(f"Error fetching validation config: {str(e)}")
        return {}


def transform_validation_config(raw_config: dict) -> dict:
    transformed = {}

    for field in raw_config.get("fields", []):
        name = field.get("fieldName")
        if not name:
            continue

        transformed[name] = {
            "required": field.get("required", False),
            "maxLength": field.get("fieldSize"),
            "fieldType": field.get("fieldType", "VARCHAR"),
            "allowedValues": field.get("allowedValues"),
            "pattern": get_validation_pattern(field.get("fieldType")),
            "aiPopulated": field.get("aiPopulated"),
            "aiConfScore": field.get("aiConfScore"),
        }

    return transformed


def get_validation_pattern(field_type: str) -> str:
    patterns = {
        "VARCHAR": None,
        "TEXT": None,
        "DATE": r"^\d{4}-\d{2}-\d{2}$",
        "TIMESTAMP": r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$",
        "JSON": None,
        "EMAIL": r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        "PHONE": r"^\+?1?\d{9,15}$",
        "NPI": r"^\d{10}$",
    }
    return patterns.get(field_type)