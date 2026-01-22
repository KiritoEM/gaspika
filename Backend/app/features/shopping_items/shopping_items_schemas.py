from pydantic import BaseModel, Field
from typing import Optional
from app.features.categories.category_schemas import CategoryOutDTO
from app.core.enums import ShoppingListItemEnum, UnitEnum
from pydantic import AwareDatetime, UUID4
# Create shopping item schema
class CreateShoppingItemDTO(BaseModel):
    food_name: str = Field(None, max_length=100, description="Nom du produit")
    quantity: float = Field(float, gt=0, description="Quantité recommandée")
    price: float = Field(float, gt=0, description="Prix unitaire")
    person_number: int = Field(int, ge=1, description="Nombre de personnes")
    unit: UnitEnum = Field(UnitEnum.UNIT, description="Unité de mesure")
    notes: Optional[str] = Field(None, description="Notes")
    storage_tips: Optional[str] = Field(None, description="Conseils de conservation")
    default_shelf_life_day: Optional[int] = Field(None, ge=1, description="Duree de jours de conservation")
    food_category_id: Optional[int] = Field(None, description="ID catégorie pour nouveau food")

#  ShoppingListItem base schema
class ShoppingListItemOut(BaseModel):
    id: int
    food_name: str
    recommended_quantity: float
    price: float
    person_number: int
    unit: UnitEnum
    status: ShoppingListItemEnum
    notes: Optional[str] = None
    storage_tips: Optional[str] = None
    default_shelf_life_day: Optional[int] = None
    shopping_list_id: int
    food_category_id: int
    user_id: UUID4
    created_at: AwareDatetime
    updated_at: AwareDatetime

    class Config:
        from_attributes = True
        
# Update shopping item schema
class UpdateShoppingItemDTO(BaseModel):
    food_name: Optional[str] = Field(None, max_length=100, description="Nom du produit")
    price: Optional[float] = Field(None, gt=0, description="Prix unitaire")
    unit: Optional[UnitEnum] = Field(None, description="Unité de mesure")
    notes: Optional[str] = Field(None, description="Notes additionnelles")    
    
# Create shopping item response schema  
class CreateShoppingItemOutDTO(BaseModel):
    message: str = Field(str, description="Message de confirmation")
    item: ShoppingListItemOut  
        
    class Config:
        from_attributes = True
        
    
# Get shopping items response schema  
class GetAllShoppingItemsDTO(BaseModel):
    results: list[ShoppingListItemOut]  
        
    class Config:
        from_attributes = True
    