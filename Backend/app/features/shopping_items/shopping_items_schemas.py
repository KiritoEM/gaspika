import datetime
from pydantic import BaseModel, Field
from typing import Optional
from app.core.enums import UnitEnum
from pydantic import AwareDatetime

# Create shopping item schema
class CreateShoppingItemDTO(BaseModel):
    name: Optional[str] = Field(None, max_length=100, description="Nom du produit")
    quantity: float = Field(float, gt=0, description="Quantité recommandée")
    price: float = Field(float, gt=0, description="Prix unitaire")
    person_number: int = Field(int, ge=1, description="Nombre de personnes")
    unit: UnitEnum = Field(UnitEnum.UNIT, description="Unité de mesure")
    default_shelf_life_day: Optional[int] = Field(None, ge=1, description="Duree de jours de conservation")
    category_id: Optional[int] = Field(None, description="ID catégorie pour nouveau food")
    food_id: Optional[int] = Field(None, description="ID Food existant (optionnel)")

class ShoppingListItemOutDTO(BaseModel):
    id: int
    recommanded_quantity: float
    price: float
    person_number: int
    unit: UnitEnum
    notes: Optional[str] = None
    food_id: int
    shopping_list_id: int
    created_at: AwareDatetime
    updated_at: AwareDatetime

    class Config:
        from_attributes = True
    
    
# Create Shopping item response schema  
class CreateShoppingItemOutDTO(BaseModel):
    message: str = Field("Item ajouté avec succès", description="Message de confirmation")
    item: ShoppingListItemOutDTO  
        
    class Config:
        from_attributes = True
        
    
# Get Shopping items response schema  
class GetAllShoppingItemsDTO(BaseModel):
    results: list[ShoppingListItemOutDTO]  
        
    class Config:
        from_attributes = True