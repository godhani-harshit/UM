import os
from dotenv import load_dotenv
from functools import lru_cache


load_dotenv()

def _get_env(key: str, default=None, cast=None):
    """Load environment variable with optional casting."""
    val = os.getenv(key, default)

    if cast and val is not None:
        try:
            return cast(val)
        except Exception:
            raise ValueError(f"Invalid value for {key}: expected {cast.__name__}")

    return val


def _get_list_env(key: str, default=None):
    val = os.getenv(key)

    if val is None:
        return default or []

    if isinstance(val, list):
        return val

    return [item.strip() for item in val.split(",")]


# ============================================================================
# CONFIG CONTAINER (functional dict-based model)
# ============================================================================

@lru_cache()
def get_settings() -> dict:

    settings = {
        "PROJECT_NAME": _get_env("PROJECT_NAME", "Curana Health UM API"),
        "VERSION": "1.0.0",
        "ENVIRONMENT": _get_env("ENVIRONMENT", "development"),
        "API_PREFIX": "/v1",
        "DEBUG": _get_env("DEBUG", "false").lower() == "true",

        # Database
        "POSTGRES_USER": _get_env("POSTGRES_USER"),
        "POSTGRES_PASSWORD": _get_env("POSTGRES_PASSWORD"),
        "POSTGRES_SERVER": _get_env("POSTGRES_SERVER"),
        "POSTGRES_PORT": _get_env("POSTGRES_PORT", 5432, int),
        "POSTGRES_DB": _get_env("POSTGRES_DB"),

        "DATABASE_URL": _get_env("DATABASE_URL"),

        "DB_POOL_SIZE": _get_env("DB_POOL_SIZE", 5, int),
        "DB_MAX_OVERFLOW": _get_env("DB_MAX_OVERFLOW", 10, int),
        "DB_POOL_TIMEOUT": _get_env("DB_POOL_TIMEOUT", 30, int),
        "DB_POOL_RECYCLE": _get_env("DB_POOL_RECYCLE", 3600, int),
        "DB_ECHO": _get_env("DB_ECHO", "false").lower() == "true",

        # Security
        "SECRET_KEY": _get_env("SECRET_KEY"),
        "ALGORITHM": "HS256",
        "ACCESS_TOKEN_EXPIRE_MINUTES": _get_env("ACCESS_TOKEN_EXPIRE_MINUTES", 60, int),
        "REFRESH_TOKEN_EXPIRE_DAYS": _get_env("REFRESH_TOKEN_EXPIRE_DAYS", 7, int),

        # Azure AD
        "AZURE_AD_TENANT_ID": _get_env("AZURE_AD_TENANT_ID"),
        "AZURE_AD_CLIENT_ID": _get_env("AZURE_AD_CLIENT_ID"),
        "AZURE_AD_CLIENT_SECRET": _get_env("AZURE_AD_CLIENT_SECRET"),
        "AZURE_AD_AUTHORITY": _get_env("AZURE_AD_AUTHORITY"),
        "AZURE_AD_ISSUER": _get_env("AZURE_AD_ISSUER"),
        "AZURE_AD_JWKS_URI": _get_env("AZURE_AD_JWKS_URI"),

        # CORS
        "CORS_ORIGINS": _get_list_env(
            "CORS_ORIGINS",
            [
                "http://localhost:3000",
                "http://localhost:3001",
                "http://localhost:8000",
                "https://app.curanahealth.com",
                "https://staging.curanahealth.com",
                "https://10.99.1.6"
            ],
        ),
        "CORS_ALLOW_CREDENTIALS": True,
        "CORS_ALLOW_METHODS": ["*"],
        "CORS_ALLOW_HEADERS": ["*"],

        # Logging
        "LOG_LEVEL": _get_env("LOG_LEVEL", "INFO"),
        "LOG_FILE_ENABLED": _get_env("LOG_FILE_ENABLED", "true").lower() == "true",
        "LOG_FILE_PATH": "logs",
        "LOG_FILE_ROTATION": "00:00",
        "LOG_FILE_RETENTION": "30 days",
        "LOG_FILE_COMPRESSION": "zip",

        # Azure Blob Storage
        "AZURE_STORAGE_CONNECTION_STRING": _get_env("AZURE_STORAGE_CONNECTION_STRING"),
        "AZURE_STORAGE_CONTAINER_NAME": _get_env("AZURE_STORAGE_CONTAINER_NAME", "um-upload-doc"),
        "AZURE_STORAGE_ACCOUNT_NAME": _get_env("AZURE_STORAGE_ACCOUNT_NAME"),
        "AZURE_STORAGE_INTAKE_CONTAINER": "intake",
        "AZURE_STORAGE_CLINICAL_CONTAINER": "clinical",

        # AI/ML
        "AI_SERVICE_ENABLED": _get_env("AI_SERVICE_ENABLED", "false").lower() == "true",
        "AI_SERVICE_ENDPOINT": _get_env("AI_SERVICE_ENDPOINT"),
        "AI_SERVICE_API_KEY": _get_env("AI_SERVICE_API_KEY"),
        "AI_CONFIDENCE_THRESHOLD": _get_env("AI_CONFIDENCE_THRESHOLD", 0.7, float),

        # Rate limiting
        "RATE_LIMIT_ENABLED": _get_env("RATE_LIMIT_ENABLED", "true").lower() == "true",
        "RATE_LIMIT_REQUESTS": _get_env("RATE_LIMIT_REQUESTS", 100, int),
        "RATE_LIMIT_PERIOD": _get_env("RATE_LIMIT_PERIOD", 60, int),

        # Session
        "SESSION_CLEANUP_ENABLED": True,
        "SESSION_CLEANUP_INTERVAL": 3600,
        "SESSION_MAX_AGE_DAYS": 30,

        # SLA timers
        "INTAKE_SLA_STANDARD": 24,
        "INTAKE_SLA_EXPEDITED": 2,
        "CLINICAL_SLA_STANDARD": 2,
        "CLINICAL_SLA_EXPEDITED": 1,
        "CLINICAL_SLA_URGENT": 0.5,
        "MD_SLA_STANDARD": 4,
        "MD_SLA_EXPEDITED": 2,
        "MD_SLA_URGENT": 1,
        "APPEALS_SLA_STANDARD": 72,
        "APPEALS_SLA_EXPEDITED": 24,

        # File uploads
        "MAX_FILE_SIZE_MB": 50,
        "ALLOWED_FILE_TYPES": [
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "image/jpeg",
            "image/png",
            "image/jpg",
            "text/plain",
        ],
    }

    # Derived values
    settings["MAX_FILE_SIZE_BYTES"] = settings["MAX_FILE_SIZE_MB"] * 1024 * 1024

    return settings


# =====================================================================
# DATABASE URL BUILDER
# =====================================================================

def get_database_url() -> str:
    s = get_settings()

    # If DATABASE_URL provided → normalize asyncpg
    if s["DATABASE_URL"]:
        url = s["DATABASE_URL"]
        if url.startswith("postgresql://") and "asyncpg" not in url:
            url = url.replace("postgresql://", "postgresql+asyncpg://")
        return url

    # Construct manually
    required = ["POSTGRES_USER", "POSTGRES_PASSWORD", "POSTGRES_SERVER", "POSTGRES_DB"]
    if not all(s[k] for k in required):
        raise ValueError("Incomplete PostgreSQL configuration.")

    return (
        f"postgresql+asyncpg://{s['POSTGRES_USER']}:{s['POSTGRES_PASSWORD']}"
        f"@{s['POSTGRES_SERVER']}:{s['POSTGRES_PORT']}/{s['POSTGRES_DB']}"
    )


def validate_settings():
    s = get_settings()

    errors = []

    # Database
    try:
        _ = get_database_url()
    except Exception as e:
        errors.append(str(e))

    # Secret key
    if not s["SECRET_KEY"]:
        errors.append("SECRET_KEY is required")
    elif len(s["SECRET_KEY"]) < 32:
        errors.append("SECRET_KEY must be at least 32 chars long")

    # Azure AD
    if not s["AZURE_AD_TENANT_ID"]:
        errors.append("AZURE_AD_TENANT_ID is required")
    if not s["AZURE_AD_CLIENT_ID"]:
        errors.append("AZURE_AD_CLIENT_ID is required")

    # Token expiry
    if s["ACCESS_TOKEN_EXPIRE_MINUTES"] < 1:
        errors.append("ACCESS_TOKEN_EXPIRE_MINUTES must be >= 1")

    if s["REFRESH_TOKEN_EXPIRE_DAYS"] < 1:
        errors.append("REFRESH_TOKEN_EXPIRE_DAYS must be >= 1")

    if errors:
        raise ValueError("Configuration errors:\n" + "\n".join(f"  - {e}" for e in errors))


# Validate on import
try:
    validate_settings()
except Exception as e:
    print(f"❌ Configuration validation failed: {e}")



if __name__ == "__main__":
    s = get_settings()
    print("=" * 70)
    print("Functional Configuration Loaded")
    print("=" * 70)
    print(f"Environment: {s['ENVIRONMENT']}")
    print(f"Database: {get_database_url().split('@')[-1]}")
    print(f"Azure Tenant: {s['AZURE_AD_TENANT_ID']}")



# import os
# from dotenv import load_dotenv

# load_dotenv()

# # General
# PROJECT_NAME = os.getenv("PROJECT_NAME", "Curana Health UM API")
# VERSION = os.getenv("VERSION", "1.0.0")
# ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
# API_PREFIX = os.getenv("API_PREFIX", "/v1")
# DEBUG = os.getenv("DEBUG", "false").lower() == "true"

# # Database
# POSTGRES_USER = os.getenv("POSTGRES_USER")
# POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
# POSTGRES_SERVER = os.getenv("POSTGRES_SERVER")
# POSTGRES_PORT = int(os.getenv("POSTGRES_PORT", 5432))
# POSTGRES_DB = os.getenv("POSTGRES_DB")
# DATABASE_URL = os.getenv("DATABASE_URL")
# DB_POOL_SIZE = int(os.getenv("DB_POOL_SIZE", 5))
# DB_MAX_OVERFLOW = int(os.getenv("DB_MAX_OVERFLOW", 10))
# DB_POOL_TIMEOUT = int(os.getenv("DB_POOL_TIMEOUT", 30))
# DB_POOL_RECYCLE = int(os.getenv("DB_POOL_RECYCLE", 3600))
# DB_ECHO = os.getenv("DB_ECHO", "false").lower() == "true"

# # Security
# SECRET_KEY = os.getenv("SECRET_KEY")
# ALGORITHM = "HS256"
# ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))
# REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))

# # Azure AD
# AZURE_AD_TENANT_ID = os.getenv("AZURE_AD_TENANT_ID")
# AZURE_AD_CLIENT_ID = os.getenv("AZURE_AD_CLIENT_ID")
# AZURE_AD_CLIENT_SECRET = os.getenv("AZURE_AD_CLIENT_SECRET")
# AZURE_AD_AUTHORITY = os.getenv("AZURE_AD_AUTHORITY")
# AZURE_AD_ISSUER = os.getenv("AZURE_AD_ISSUER")
# AZURE_AD_JWKS_URI = os.getenv("AZURE_AD_JWKS_URI")

# # CORS
# CORS_ORIGINS = [o.strip() for o in os.getenv("CORS_ORIGINS", 
#     "http://localhost:3000,http://localhost:3001,http://localhost:8000,"
#     "https://app.curanahealth.com,https://staging.curanahealth.com,https://10.99.1.6").split(",")]
# CORS_ALLOW_CREDENTIALS = True
# CORS_ALLOW_METHODS = ["*"]
# CORS_ALLOW_HEADERS = ["*"]

# # Logging
# LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
# LOG_FILE_ENABLED = os.getenv("LOG_FILE_ENABLED", "true").lower() == "true"
# LOG_FILE_PATH = os.getenv("LOG_FILE_PATH", "logs")
# LOG_FILE_ROTATION = os.getenv("LOG_FILE_ROTATION", "00:00")
# LOG_FILE_RETENTION = os.getenv("LOG_FILE_RETENTION", "30 days")
# LOG_FILE_COMPRESSION = os.getenv("LOG_FILE_COMPRESSION", "zip")

# # Azure Blob Storage
# AZURE_STORAGE_CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
# AZURE_STORAGE_CONTAINER_NAME = os.getenv("AZURE_STORAGE_CONTAINER_NAME", "um-upload-doc")
# AZURE_STORAGE_ACCOUNT_NAME = os.getenv("AZURE_STORAGE_ACCOUNT_NAME")
# AZURE_STORAGE_INTAKE_CONTAINER = "intake"
# AZURE_STORAGE_CLINICAL_CONTAINER = "clinical"

# # AI/ML
# AI_SERVICE_ENABLED = os.getenv("AI_SERVICE_ENABLED", "false").lower() == "true"
# AI_SERVICE_ENDPOINT = os.getenv("AI_SERVICE_ENDPOINT")
# AI_SERVICE_API_KEY = os.getenv("AI_SERVICE_API_KEY")
# AI_CONFIDENCE_THRESHOLD = float(os.getenv("AI_CONFIDENCE_THRESHOLD", 0.7))

# # Rate limiting
# RATE_LIMIT_ENABLED = os.getenv("RATE_LIMIT_ENABLED", "true").lower() == "true"
# RATE_LIMIT_REQUESTS = int(os.getenv("RATE_LIMIT_REQUESTS", 100))
# RATE_LIMIT_PERIOD = int(os.getenv("RATE_LIMIT_PERIOD", 60))

# # Session
# SESSION_CLEANUP_ENABLED = True
# SESSION_CLEANUP_INTERVAL = 3600
# SESSION_MAX_AGE_DAYS = 30

# # SLA timers
# INTAKE_SLA_STANDARD = 24
# INTAKE_SLA_EXPEDITED = 2
# CLINICAL_SLA_STANDARD = 2
# CLINICAL_SLA_EXPEDITED = 1
# CLINICAL_SLA_URGENT = 0.5
# MD_SLA_STANDARD = 4
# MD_SLA_EXPEDITED = 2
# MD_SLA_URGENT = 1
# APPEALS_SLA_STANDARD = 72
# APPEALS_SLA_EXPEDITED = 24

# # File uploads
# MAX_FILE_SIZE_MB = 50
# ALLOWED_FILE_TYPES = [
#     "application/pdf",
#     "application/msword",
#     "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
#     "image/jpeg",
#     "image/png",
#     "image/jpg",
#     "text/plain",
# ]
# MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024

# # SMTP
# SMTP_USER = os.getenv("SMTP_USER")
# SMTP_PASSWORD = os.getenv("SMTP_PASSWORD")
# SMTP_SERVER = os.getenv("SMTP_SERVER")
# SMTP_PORT = os.getenv("SMTP_PORT")