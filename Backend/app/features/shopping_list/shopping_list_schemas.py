from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field
from app.core.schemas import PageParams
from app.core.enums import ShoppingListIntervalDateEnum, ShoppingListStatusEnum

# Create ShoppingListOut schema
class ShoppingListOutDTO(BaseModel): 
    id: int
    week_number: int
    name: str
    total_estimated_cost: float
    status: str
    created_at: str
    user_id: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
        
# Get all shopping lists filter params
class GetAllListsFilterParams(BaseModel):
    status :  Optional[ShoppingListStatusEnum] = Field(None, description="Statut de la liste")
    dateInterval: Optional[ShoppingListIntervalDateEnum] = Field(None, description="intervalle de date")
    page: int = Field(1, ge=1, description="Page")
    limit: int = Field(10, ge=1, le=100, description="Taille page")
