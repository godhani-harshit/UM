from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from azure.storage.blob import BlobServiceClient, BlobSasPermissions, generate_blob_sas
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta
import uuid
import os
import aiohttp
from io import BytesIO

from app.core.config import get_settings
from app.core.database import get_session
from app.services.document_service import create_authorization_record
from app.core.logging import logger
from fastapi.responses import StreamingResponse
from azure.storage.blob.aio import BlobClient

router = APIRouter()

# Initialize Blob Service Client
s = get_settings()
blob_service_client = BlobServiceClient.from_connection_string(s["AZURE_STORAGE_CONNECTION_STRING"])
container_name = s["AZURE_STORAGE_CONTAINER_NAME"]

def generate_unique_filename(original_filename: str) -> str:
    """Generate a unique filename to avoid conflicts"""
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    unique_id = uuid.uuid4().hex[:8]
    file_extension = os.path.splitext(original_filename)[1]
    safe_filename = f"{timestamp}_{unique_id}{file_extension}"
    return safe_filename

def generate_sas_url(blob_name: str, expires_in_minutes: int = 10) -> str:
    """Generate SAS URL for direct blob upload"""
    expire_time = datetime.utcnow() + timedelta(minutes=expires_in_minutes)
    
    sas_token = generate_blob_sas(
        account_name=blob_service_client.account_name,
        container_name=container_name,
        blob_name=blob_name,
        account_key=s["AZURE_STORAGE_CONNECTION_STRING"].split("AccountKey=")[1].split(";")[0],
        permission=BlobSasPermissions(write=True, create=True),
        expiry=expire_time
    )
    
    return f"https://{blob_service_client.account_name}.blob.core.windows.net/{container_name}/{blob_name}?{sas_token}"

async def upload_via_sas_url(file_bytes: bytes, blob_name: str, content_type: str = "application/octet-stream") -> str:
    """Upload file to Azure Blob Storage using SAS URL"""
    sas_url = generate_sas_url(blob_name)
    
    async with aiohttp.ClientSession() as session:
        async with session.put(
            sas_url,
            data=BytesIO(file_bytes),
            headers={
                'x-ms-blob-type': 'BlockBlob',
                'Content-Type': content_type,
                'Content-Length': str(len(file_bytes))
            }
        ) as response:
            if response.status not in [200, 201]:
                error_text = await response.text()
                raise Exception(f"Azure upload failed: {response.status} - {error_text}")
    
    return f"https://{blob_service_client.account_name}.blob.core.windows.net/{container_name}/{blob_name}"

@router.post("/documents/upload", summary="Upload document and create authorization record")
async def upload_document_and_create_record(
    file: UploadFile = File(...),
    source: str = "Upload",
    session: AsyncSession = Depends(get_session)
):
    """
    Upload a document to Azure Blob Storage and create an authorization record.
    
    This endpoint uses SAS URLs internally for secure direct upload to Azure.
    """
    try:
        # Validate file
        if not file.filename or file.filename.strip() == "":
            raise HTTPException(
                status_code=400,
                detail="File name cannot be empty"
            )

        # Read file bytes and metadata
        file_bytes = await file.read()
        original_filename = file.filename
        file_size = len(file_bytes)

        # Generate unique filename to avoid conflicts
        unique_filename = generate_unique_filename(original_filename)
        
        logger.info(f" Uploading file: {original_filename} as {unique_filename} ({file_size} bytes)")

        # Upload to Azure using SAS URL (more secure and efficient)
        file_url = await upload_via_sas_url(
            file_bytes=file_bytes,
            blob_name=unique_filename,
            content_type=file.content_type or "application/octet-stream"
        )

        logger.info(f" File uploaded to Azure: {file_url}")

        # Create authorization record in database
        record = await create_authorization_record(
            session=session,
            file_name=unique_filename,
            file_url=file_url,
            file_size=file_size,
            file_arrival_time=datetime.utcnow()
        )

        logger.info(f" Authorization record created: {record.id}")

        return {
            "message": "File uploaded and authorization created successfully",
            "authorization_id": record.id,
            "file_name": record.file_name,
            "original_filename": original_filename,
            "file_url": record.file_url,
            "file_size": record.file_size,
            "file_arrival_time": record.file_arrival_time,
            "status": record.status,
            "member_name": record.member_name,
            "health_plan": record.health_plan,
            "priority": record.priority
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f" Upload failed for {file.filename}: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail=f"Upload failed: {str(e)}"
        )

@router.get("/documents/{file_name}", summary="Download and stream PDF document")
async def get_document(file_name: str):
    """
    Fetch a PDF from Azure Blob Storage and return it as a streamed response.
    """
    try:
        blob_client = BlobClient.from_connection_string(
            conn_str=s["AZURE_STORAGE_CONNECTION_STRING"],
            container_name=container_name,
            blob_name=file_name
        )

        # Check if blob exists
        exists = await blob_client.exists()
        if not exists:
            raise HTTPException(status_code=404, detail="Requested document not found")

        # Download file as stream
        stream = await blob_client.download_blob()

        # Return PDF for display in browser
        return StreamingResponse(
            stream.chunks(),
            media_type="application/pdf",
            headers={
                "Content-Disposition": f"inline; filename={file_name}"
            }
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f" Failed to fetch document {file_name}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving document: {str(e)}"
        )

@router.get("/documents/health")
async def storage_health_check():
    """
    Check Azure Blob Storage health status
    """
    try:
        # Test container access
        container_client = blob_service_client.get_container_client(container_name)
        container_client.get_container_properties()
        
        return {
            "status": "healthy",
            "storage_account": blob_service_client.account_name,
            "container": container_name,
            "message": "Azure Blob Storage is accessible"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "message": f"Azure Blob Storage error: {str(e)}"
        }