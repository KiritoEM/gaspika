# Image schema base
from typing import Optional
from pydantic import UUID4, AwareDatetime, BaseModel


class ImageSchema(BaseModel):
    id: UUID4
    filename: str
    path: str
    size: int
    provider: str
    file_id: Optional[str]
    delete_url: str
    updated_at: AwareDatetime
    
    class Config:
        from_attributes= True