from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, Field
from app.core.enums import ShoppingListIntervalDateEnum, ShoppingListStatusEnum

# Create Shopping list schema
class CreateShoppingListDTO(BaseModel):
    week_number: int = Field(..., ge=1, le=53, description="Numéro de semaine")
    name: Optional[str] = Field(None, max_length=200, description="Nom de la liste")

#  ShoppingList base schema
class BaseShoppingList(BaseModel): 
    id: int
    week_number: int
    name: str
    total_estimated_cost: float
    status: str
    items_count: Optional[int] = 0
    created_at: str
    user_id: UUID
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
        
#  Create Shopping list response schema
class CreateShoppingListOutDTO(BaseModel): 
    data: BaseShoppingList
    message: str
        
        
# Get all shopping lists filter params
class GetAllListsFilterParams(BaseModel):
    status :  Optional[ShoppingListStatusEnum] = Field(None, description="Statut de la liste")
    dateInterval: Optional[ShoppingListIntervalDateEnum] = Field(None, description="intervalle de date")
    page: int = Field(1, ge=1, description="Page")
    limit: int = Field(10, ge=1, le=100, description="Taille page")
