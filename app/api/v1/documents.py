# app/api/v1/documents.py
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from azure.storage.blob import BlobServiceClient, BlobSasPermissions, generate_blob_sas
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta
import uuid
import os
import aiohttp
from io import BytesIO
from app.core.config import get_settings
from app.core.database import get_db
from app.services.document_service import create_authorization_record, check_file_exists
from app.core.logging import logger
from fastapi.responses import StreamingResponse
from azure.storage.blob.aio import BlobClient
from fastapi import status

router = APIRouter()

# Lazy Blob client initialization
def get_blob_service_client():
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
    return get_settings()["AZURE_STORAGE_CONTAINER_NAME"] or ""

def generate_sas_url(blob_name: str, expires_in_minutes: int = 10) -> str:
    """Generate SAS URL for direct blob upload"""
    expire_time = datetime.utcnow() + timedelta(minutes=expires_in_minutes)
    
    bsc = get_blob_service_client()
    if bsc is None:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Storage not configured")
    container_name = get_container_name()
    sas_token = generate_blob_sas(
        account_name=bsc.account_name,
        container_name=container_name,
        blob_name=blob_name,
        account_key=get_settings()["AZURE_STORAGE_CONNECTION_STRING"].split("AccountKey=")[1].split(";")[0],
        permission=BlobSasPermissions(write=True, create=True),
        expiry=expire_time
    )
    
    return f"https://{bsc.account_name}.blob.core.windows.net/{container_name}/{blob_name}?{sas_token}"

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
    
    bsc = get_blob_service_client()
    container_name = get_container_name()
    return f"https://{bsc.account_name}.blob.core.windows.net/{container_name}/{blob_name}"

@router.post("/documents/upload", summary="Upload document and create authorization record")
async def upload_document_and_create_record(
    file: UploadFile = File(...),
    source: str = "Upload",
    session: AsyncSession = Depends(get_db)
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

        # Check if file already exists
        file_exists = await check_file_exists(session, original_filename)
        if file_exists:
            raise HTTPException(
                status_code=400,
                detail="File name already exists. Please upload with different name"
            )

        logger.info(f" Uploading file: {original_filename} ({file_size} bytes)")

        # Upload to Azure using SAS URL (more secure and efficient)
        file_url = await upload_via_sas_url(
            file_bytes=file_bytes,
            blob_name=original_filename,
            content_type=file.content_type or "application/octet-stream"
        )

        logger.info(f" File uploaded to Azure: {file_url}")

        # Create authorization record in database
        record = await create_authorization_record(
            session=session,
            file_name=original_filename,
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

@router.get("/documents/{document_id}")
async def get_document_by_document_id(
    document_id: str,
    session: AsyncSession = Depends(get_db)
):
    """
    Get document by document_id from authorization record
    """
    try:
        # Get file details from database
        from sqlalchemy import text
        
        query = text("""
            SELECT file_name, file_url 
            FROM um.um_authorizations 
            WHERE document_id = :document_id
        """)
        
        result = await session.execute(query, {"document_id": document_id})
        record = result.fetchone()
        
        if not record:
            raise HTTPException(status_code=404, detail="Document not found")
        
        file_name = record.file_name
        file_url = record.file_url
        
        # Download from Azure Blob Storage
        bsc = get_blob_service_client()
        if bsc is None:
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Storage not configured")
        blob_client = BlobClient.from_connection_string(
            conn_str=get_settings()["AZURE_STORAGE_CONNECTION_STRING"],
            container_name=get_container_name(),
            blob_name=file_name
        )

        # Check if blob exists
        exists = await blob_client.exists()
        if not exists:
            raise HTTPException(status_code=404, detail="Requested document not found in storage")

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
        logger.error(f" Failed to fetch document {document_id}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving document: {str(e)}"
        )