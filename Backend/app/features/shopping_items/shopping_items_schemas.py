from pydantic import BaseModel, Field
from typing import Optional
from app.features.foods.food_schemas import FoodOutDTO
from app.core.enums import ShoppingListItemEnum, UnitEnum
from pydantic import AwareDatetime

# Create shopping item schema
class CreateShoppingItemDTO(BaseModel):
    name: Optional[str] = Field(None, max_length=100, description="Nom du produit")
    quantity: float = Field(float, gt=0, description="Quantité recommandée")
    price: float = Field(float, gt=0, description="Prix unitaire")
    person_number: int = Field(int, ge=1, description="Nombre de personnes")
    unit: UnitEnum = Field(UnitEnum.UNIT, description="Unité de mesure")
    notes: Optional[str] = Field(None, description="Notes")
    default_shelf_life_day: Optional[int] = Field(None, ge=1, description="Duree de jours de conservation")
    category_id: Optional[int] = Field(None, description="ID catégorie pour nouveau food")
    food_id: Optional[int] = Field(None, description="ID Food existant (optionnel)")

#  ShoppingListItem base schema
class ShoppingListItemOutDTO(BaseModel):
    id: int
    recommanded_quantity: float
    price: float
    person_number: int
    unit: UnitEnum
    status: ShoppingListItemEnum
    notes: Optional[str] = None
    food: FoodOutDTO
    shopping_list_id: int
    created_at: AwareDatetime
    updated_at: AwareDatetime

    class Config:
        from_attributes = True
        
# Update shopping item schema
class UpdateShoppingItemDTO(BaseModel):
    price: Optional[float] =  Field(float, gt=0, description="Prix unitaire")
    notes: Optional[str] = Field(None, description="Notes")
    unit: Optional[UnitEnum] = Field(None, description="Unité de mesure")
    
    
# Create shopping item response schema  
class CreateShoppingItemOutDTO(BaseModel):
    message: str = Field("Item ajouté avec succès", description="Message de confirmation")
    item: ShoppingListItemOutDTO  
        
    class Config:
        from_attributes = True
        
    
# Get shopping items response schema  
class GetAllShoppingItemsDTO(BaseModel):
    results: list[ShoppingListItemOutDTO]  
        
    class Config:
        from_attributes = True
    