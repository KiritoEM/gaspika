from pydantic import BaseModel, Field
from typing import Optional

class CreateCategoryDTO(BaseModel):
    name: str = Field(..., max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    ml_category: str = Field(..., max_length=100)

class BaseCategory(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    ml_category: str
    
    class Config:
        from_attributes = True

class CreateCategoryOutDTO(BaseModel):
    message: str
        
class CategoryOutDTO(BaseModel):
    data: list[BaseCategory]
    
    class Config:
        from_attributes = True