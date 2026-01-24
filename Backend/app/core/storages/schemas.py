from typing import Optional
from pydantic import BaseModel


class UploadResult(BaseModel):
    success: bool
    url: Optional[str]
    file_id: Optional[str]
    provider: Optional[str]
    error: Optional[str] = None