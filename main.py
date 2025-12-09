from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from time import time
from datetime import datetime

from app.core.config import get_settings
from app.core.database import init_db, test_connection
from app.core.logging import log_api_request, log_api_response

# API routers
from app.api.v1.auth import router as auth_router
from app.api.v1.documents import router as documents_router
from app.api.v1.intake import router as intake_router
from app.api.v1.reference import router as reference_router
from app.api.v1.dashboard import router as dashboard_router
from app.api.v1.case_lock import router as case_lock_router
from app.api.v1.users import router as users_router
from app.api.v1.clinical import router as clinical_router
from app.api.v1.medical_director import router as medical_director_router
from app.api.v1.appeals_grievances import router as appeals_grievances_router

# ============================================================================#
# FASTAPI APP INITIALIZATION
# ============================================================================#
s = get_settings()
app = FastAPI(
    title=s["PROJECT_NAME"],
    version=s["VERSION"],
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# ============================================================================#
# MIDDLEWARE
# ============================================================================#
app.add_middleware(
    CORSMiddleware,
    allow_origins=s["CORS_ORIGINS"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time()
    log_api_request(request.method, request.url.path)
    response = await call_next(request)
    duration_ms = (time() - start_time) * 1000
    response.headers["X-Process-Time"] = f"{duration_ms:.2f}ms"
    log_api_response(
        request.method, request.url.path, response.status_code, duration_ms
    )
    return response


# ============================================================================#
# EVENT HANDLERS
# ============================================================================#
@app.on_event("startup")
async def on_startup():
    init_db()


# ============================================================================#
# ROUTER REGISTRATION
# ============================================================================#
app.include_router(auth_router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(dashboard_router, prefix="/api/v1", tags=["Dashboard"])
app.include_router(documents_router, prefix="/api/v1", tags=["Documents"])
app.include_router(intake_router, prefix="/api/v1", tags=["Intake"])
app.include_router(reference_router, prefix="/api/v1", tags=["References"])
app.include_router(case_lock_router, prefix="/api/v1", tags=["Intake"])
app.include_router(users_router, prefix="/api/v1", tags=["Users"])
app.include_router(clinical_router, prefix="/api/v1", tags=["Clinical Review"])
app.include_router(medical_director_router, prefix="/api/v1", tags=["Medical Director"])
app.include_router(
    appeals_grievances_router, prefix="/api/v1", tags=["Appeals & Grievances"]
)


@app.get("/health", tags=["Health"])
async def health_check():
    db_healthy = await check_database_health()
    return {
        "status": "ok",
        "app": s["PROJECT_NAME"],
        "version": s["VERSION"],
        "environment": s["ENVIRONMENT"],
        "timestamp": datetime.utcnow().isoformat(),
        "modules": {"database": "healthy" if db_healthy else "degraded"},
    }


# ============================================================================#
# HELPER FUNCTIONS
# ============================================================================#
async def check_database_health() -> bool:
    try:
        return test_connection()
    except Exception:
        return False


# ============================================================================#
# DEVELOPMENT ENTRYPOINT
# ============================================================================#
if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
