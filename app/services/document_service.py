import re
import httpx
import hashlib
import aiohttp
from io import BytesIO
from fastapi import status
from sqlalchemy import text
from typing import Optional
from fastapi import HTTPException
from app.core.logging import logger
from app.core.config import get_settings
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.authorization import Authorization
from datetime import datetime, date, timedelta, timezone
from azure.storage.blob import BlobServiceClient, BlobSasPermissions, generate_blob_sas

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


def validate_blob_url(blob_url: str) -> bool:
    if not blob_url:
        return False
    
    # Check if it's a valid HTTP/HTTPS URL
    if not blob_url.startswith(('http://', 'https://')):
        return False
    
    # Check if it contains blob.core.windows.net (Azure Blob Storage)
    settings = get_settings()
    storage_account = settings.get("AZURE_STORAGE_ACCOUNT_NAME", "")
    
    # Basic validation - should contain storage account or be a valid blob URL
    if storage_account and storage_account in blob_url:
        return True
    
    # Generic blob storage URL pattern
    if re.match(r'https?://[\w\-]+\.blob\.core\.windows\.net/.+', blob_url):
        return True
    
    return False


async def download_blob_content(blob_url: str, timeout: float = 60.0) -> bytes:
    try:
        logger.info(f"📥 Downloading blob from: {blob_url}")
        
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.get(blob_url)
            
            if response.status_code == 200:
                content = response.content
                logger.info(f"✅ Downloaded {len(content)} bytes from blob storage")
                return content
            else:
                error_msg = f"Failed to download blob: HTTP {response.status_code}"
                logger.error(f"❌ {error_msg}")
                raise Exception(error_msg)
                
    except httpx.TimeoutException:
        error_msg = f"Blob download timeout after {timeout}s"
        logger.error(f"❌ {error_msg}")
        raise Exception(error_msg)
        
    except Exception as e:
        error_msg = f"Blob download failed: {str(e)}"
        logger.error(f"❌ {error_msg}")
        raise Exception(error_msg)


async def get_blob_metadata(blob_url: str) -> dict:
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            # HEAD request to get metadata without downloading
            response = await client.head(blob_url)
            
            if response.status_code == 200:
                return {
                    "size": int(response.headers.get("content-length", 0)),
                    "content_type": response.headers.get("content-type", ""),
                    "last_modified": response.headers.get("last-modified", ""),
                    "etag": response.headers.get("etag", "")
                }
            else:
                raise Exception(f"Failed to get blob metadata: HTTP {response.status_code}")
                
    except Exception as e:
        logger.error(f"❌ Failed to get blob metadata: {str(e)}")
        raise


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================


def get_blob_service_client():
    """Lazy Blob client initialization"""
    s = get_settings()
    conn = s["AZURE_STORAGE_CONNECTION_STRING"]
    if not conn:
        return None
    try:
        return BlobServiceClient.from_connection_string(conn)
    except Exception as e:
        logger.warning(f"Blob service client not initialized: {e}")
        return None


def get_container_name():
    """Get Azure Blob Storage container name"""
    return get_settings()["AZURE_STORAGE_CONTAINER_NAME"] or ""


def generate_sas_url(blob_name: str, expires_in_minutes: int = 10) -> str:
    """Generate SAS URL for direct blob upload"""
    expire_time = datetime.utcnow() + timedelta(minutes=expires_in_minutes)

    bsc = get_blob_service_client()
    if bsc is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Storage not configured",
        )

    container_name = get_container_name()
    sas_token = generate_blob_sas(
        account_name=bsc.account_name,
        container_name=container_name,
        blob_name=blob_name,
        account_key=get_settings()["AZURE_STORAGE_CONNECTION_STRING"]
        .split("AccountKey=")[1]
        .split(";")[0],
        permission=BlobSasPermissions(write=True, create=True),
        expiry=expire_time,
    )

    return f"https://{bsc.account_name}.blob.core.windows.net/{container_name}/{blob_name}?{sas_token}"


async def upload_via_sas_url(
    file_bytes: bytes, blob_name: str, content_type: str = "application/octet-stream"
) -> str:
    """Upload file to Azure Blob Storage using SAS URL"""
    sas_url = generate_sas_url(blob_name)

    async with aiohttp.ClientSession() as session:
        async with session.put(
            sas_url,
            data=BytesIO(file_bytes),
            headers={
                "x-ms-blob-type": "BlockBlob",
                "Content-Type": content_type,
                "Content-Length": str(len(file_bytes)),
            },
        ) as response:
            if response.status not in [200, 201]:
                error_text = await response.text()
                raise Exception(
                    f"Azure upload failed: {response.status} - {error_text}"
                )

    bsc = get_blob_service_client()
    container_name = get_container_name()
    return (
        f"https://{bsc.account_name}.blob.core.windows.net/{container_name}/{blob_name}"
    )


def calculate_checksum(file_bytes: bytes) -> str:
    """Calculate MD5 checksum of file"""
    return hashlib.md5(file_bytes).hexdigest()
