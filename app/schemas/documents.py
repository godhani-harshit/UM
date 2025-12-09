from pydantic import BaseModel
from datetime import datetime


# Document response schemas
class DocumentUploadResponse(BaseModel):
    document_id: str
    status: str = "queued"


class DocumentMetadataResponse(BaseModel):
    document_id: str
    filename: str
    file_size: int
    checksum: str
    transfer_status: str
    sftp_path: str | None = None
    blob_url: str | None = None
    created_date: datetime
    modified_date: datetime