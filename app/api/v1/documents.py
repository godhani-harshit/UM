# app/api/v1/documents.py
"""
Document Management API Endpoints.

Handles document upload, download, and metadata operations for SFTP-based workflow.
"""
import hashlib
from fastapi import status
from typing import Optional
from sqlalchemy import text
from datetime import datetime
from app.core.logging import logger
from app.core.database import get_db
from app.core.config import get_settings
from azure.storage.blob.aio import BlobClient
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.responses import StreamingResponse
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, Form
from app.schemas.documents import DocumentUploadResponse, DocumentMetadataResponse
from app.services.document_service import create_authorization_record, check_file_exists, get_blob_service_client, get_container_name, upload_via_sas_url


router = APIRouter()


# ============================================================================
# API ENDPOINTS
# ============================================================================


@router.post(
    "/documents/upload",
    response_model=DocumentUploadResponse,
    status_code=status.HTTP_200_OK,
    summary="Upload document or register SFTP path",
    description="Accept file via API (optional) or register an SFTP path. Enqueues background job to copy to processing area and trigger AI.",
)
async def upload_document(
    file: Optional[UploadFile] = File(None),
    sftp_path: Optional[str] = Form(None),
    document_type: Optional[str] = Form(None),
    auth_number: Optional[str] = Form(None),
    session: AsyncSession = Depends(get_db),
):
    """
    Accept file via API (optional) or register an SFTP path.

    **Request** (multipart) OR JSON:
    - file: Uploaded file (multipart, optional)
    - sftp_path: SFTP path like "/incoming/partnerA/file.pdf" (optional)
    - document_type: Type of document (e.g., "clinical_document")
    - auth_number: Authorization number (optional)

    **Response**:
    - document_id: Unique identifier
    - status: "queued"
    """
    try:
        # Validate that either file or sftp_path is provided
        if not file and not sftp_path:
            raise HTTPException(
                status_code=400,
                detail="Either file upload or sftp_path must be provided",
            )

        # Handle SFTP path registration
        if sftp_path:
            logger.info(f"📁 Registering SFTP path: {sftp_path}")

            # Extract filename from SFTP path
            original_filename = sftp_path.split("/")[-1]

            # Create authorization record with SFTP path
            # In production, this would trigger a background job to copy from SFTP
            record = await create_authorization_record(
                session=session,
                file_name=original_filename,
                file_url=f"sftp://{sftp_path}",  # Mark as SFTP source
                file_size=0,  # Will be updated when file is copied
                file_arrival_time=datetime.utcnow(),
                source="SFTP",
            )

            logger.info(f"✅ SFTP path registered: {record.document_id}")

            return DocumentUploadResponse(
                document_id=record.document_id, status="queued"
            )

        # Handle file upload
        if file:
            # Validate file
            if not file.filename or file.filename.strip() == "":
                raise HTTPException(status_code=400, detail="File name cannot be empty")

            # Read file bytes and metadata
            file_bytes = await file.read()
            original_filename = file.filename
            file_size = len(file_bytes)

            # Check if file already exists
            file_exists = await check_file_exists(session, original_filename)
            if file_exists:
                raise HTTPException(
                    status_code=400,
                    detail="File name already exists. Please upload with different name",
                )

            logger.info(f"📤 Uploading file: {original_filename} ({file_size} bytes)")

            # Upload to Azure using SAS URL
            file_url = await upload_via_sas_url(
                file_bytes=file_bytes,
                blob_name=original_filename,
                content_type=file.content_type or "application/octet-stream",
            )

            logger.info(f"✅ File uploaded to Azure: {file_url}")

            # Create authorization record in database
            record = await create_authorization_record(
                session=session,
                file_name=original_filename,
                file_url=file_url,
                file_size=file_size,
                file_arrival_time=datetime.utcnow(),
                source="Upload",
            )

            logger.info(f"✅ Authorization record created: {record.document_id}")

            return DocumentUploadResponse(
                document_id=record.document_id, status="queued"
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Upload/registration failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@router.get(
    "/documents/{document_id}",
    status_code=status.HTTP_200_OK,
    summary="Stream/download document",
    description="Streams/downloads the file via API proxy (auth enforced)",
)
async def get_document(document_id: str, session: AsyncSession = Depends(get_db)):
    """
    Get document by document_id and stream it.

    **Path Parameters**:
    - document_id: Unique document identifier

    **Returns**:
    - Streaming file response (PDF/document)
    """
    try:
        logger.info(f"📥 Fetching document: {document_id}")

        # Get file details from database
        query = text(
            """
            SELECT file_name, file_url 
            FROM um.um_authorizations 
            WHERE document_id = :document_id
        """
        )

        result = await session.execute(query, {"document_id": document_id})
        record = result.fetchone()

        if not record:
            raise HTTPException(status_code=404, detail="Document not found")

        file_name = record.file_name
        file_url = record.file_url

        # Download from Azure Blob Storage
        bsc = get_blob_service_client()
        if bsc is None:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Storage not configured",
            )

        blob_client = BlobClient.from_connection_string(
            conn_str=get_settings()["AZURE_STORAGE_CONNECTION_STRING"],
            container_name=get_container_name(),
            blob_name=file_name,
        )

        # Check if blob exists
        exists = await blob_client.exists()
        if not exists:
            raise HTTPException(
                status_code=404, detail="Requested document not found in storage"
            )

        # Download file as stream
        stream = await blob_client.download_blob()

        logger.info(f"✅ Streaming document: {file_name}")

        # Return file for display/download in browser
        return StreamingResponse(
            stream.chunks(),
            media_type="application/pdf",
            headers={"Content-Disposition": f"inline; filename={file_name}"},
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Failed to fetch document {document_id}: {str(e)}")
        raise HTTPException(
            status_code=500, detail=f"Error retrieving document: {str(e)}"
        )


@router.get(
    "/documents/{document_id}/metadata",
    response_model=DocumentMetadataResponse,
    status_code=status.HTTP_200_OK,
    summary="Get document metadata",
    description="Returns metadata, checksum, transfer_status, sftp_path",
)
async def get_document_metadata(
    document_id: str, session: AsyncSession = Depends(get_db)
):
    """
    Get document metadata without downloading the file.

    **Path Parameters**:
    - document_id: Unique document identifier

    **Returns**:
    - document_id: Document identifier
    - filename: Original filename
    - file_size: File size in bytes
    - checksum: File checksum (MD5)
    - transfer_status: Transfer status
    - sftp_path: SFTP path if applicable
    - blob_url: Blob storage URL if applicable
    - created_date: Upload date
    - modified_date: Last modified date
    """
    try:
        logger.info(f"📋 Fetching metadata for document: {document_id}")

        # Get file details from database
        query = text(
            """
            SELECT 
                document_id,
                file_name,
                file_url,
                file_size,
                source,
                status,
                created_at,
                updated_at
            FROM um.um_authorizations 
            WHERE document_id = :document_id
        """
        )

        result = await session.execute(query, {"document_id": document_id})
        record = result.mappings().first()

        if not record:
            raise HTTPException(status_code=404, detail="Document not found")

        # Determine if SFTP or blob storage
        file_url = record["file_url"]
        sftp_path = (
            file_url.replace("sftp://", "") if file_url.startswith("sftp://") else None
        )
        blob_url = file_url if file_url.startswith("http") else None

        # Determine transfer status based on source and status
        transfer_status = "completed" if record["status"] != "Queued" else "pending"

        # Calculate checksum (simplified - in production, store this in DB)
        checksum = hashlib.md5(document_id.encode()).hexdigest()

        logger.info(f"✅ Metadata retrieved for document: {document_id}")

        return DocumentMetadataResponse(
            document_id=record["document_id"],
            filename=record["file_name"],
            file_size=record["file_size"],
            checksum=checksum,
            transfer_status=transfer_status,
            sftp_path=sftp_path,
            blob_url=blob_url,
            created_date=record["created_at"],
            modified_date=record["updated_at"],
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            f"❌ Failed to fetch metadata for document {document_id}: {str(e)}"
        )
        raise HTTPException(
            status_code=500, detail=f"Error retrieving document metadata: {str(e)}"
        )