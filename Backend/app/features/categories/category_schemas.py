from pydantic import BaseModel, Field
from typing import Optional

class CreateCategoryDTO(BaseModel):
    name: str = Field(..., max_length=100, description="Nom de la catégorie")
    description: Optional[str] = Field(None, max_length=500, description="Description")

class BaseCategory(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    
    class Config:
        from_attributes = True
        
class CategoryOutDTO(BaseModel):
    data: BaseCategory
    
    class Config:
        from_attributes = True