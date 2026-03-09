from pydantic import BaseModel, Field
from typing import Optional
from app.features.images_upload.images_schemas import ImageSchema
from app.features.categories.category_schemas import BaseCategory, CategoryOutDTO
from app.core.enums import ShoppingListItemEnum, UnitEnum
from pydantic import AwareDatetime, UUID4
from fastapi import File, Form, UploadFile
from typing import Annotated

# Create shopping item schema
class CreateShoppingItemDTO(BaseModel):
    food_name: str = Field(..., max_length=100)
    quantity: float = Field(..., gt=0)
    price: float = Field(..., gt=0)
    person_number: int = Field(..., ge=1)
    unit: UnitEnum = Field(UnitEnum.UNIT)
    notes: Optional[str] = Field(None)
    storage_tips: Optional[str] = Field(None)
    default_shelf_life_day: Optional[int] = Field(None, ge=1)
    food_category_id: Optional[int] = Field(None)
    image: Optional[Annotated[UploadFile, File()]] = Field(None)

    class Config:
        from_attributes = True

    @classmethod
    def as_form(
        cls,
        food_name: Annotated[str, Form(..., max_length=100)],
        quantity: Annotated[float, Form(..., gt=0)],
        price: Annotated[float, Form(..., gt=0)],
        person_number: Annotated[int, Form(..., ge=1)],
        unit: Annotated[str, Form(UnitEnum.UNIT.value)],
        notes: Annotated[Optional[str], Form(None)],
        storage_tips: Annotated[Optional[str], Form(None)],
        default_shelf_life_day: Annotated[Optional[int], Form(None)],
        food_category_id: Annotated[Optional[int], Form(None)]
    ) -> "CreateShoppingItemDTO":
        return cls(
            food_name=food_name,
            quantity=quantity,
            price=price,
            person_number=person_number,
            unit=UnitEnum(unit),
            notes=notes,
            storage_tips=storage_tips,
            default_shelf_life_day=default_shelf_life_day,
            food_category_id=food_category_id
        )


#  ShoppingListItem base schema
class BaseShoppingListItem(BaseModel):
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
    category: BaseCategory
    user_id: UUID4
    image: Optional[ImageSchema] 
    created_at: AwareDatetime
    updated_at: AwareDatetime

    class Config:
        from_attributes = True

# Update shopping item schema
class UpdateShoppingItemDTO(BaseModel):
    food_name: Optional[str] = Field(None, max_length=100)
    price: Optional[float] = Field(None, gt=0)
    unit: Optional[UnitEnum] = Field(None)
    recommanded_quantity: Optional[float] = Field(None, gt=0)
    notes: Optional[str] = Field(None)

# Update shopping item response schema
class UpdateShoppingItemOutDTO(BaseModel):
    message: str
        
    class Config:
        from_attributes = True


# Create shopping item response schema
class CreateShoppingItemOutDTO(BaseModel):
    message: str = Field(str, description="Message de confirmation")

    class Config:
        from_attributes = True

# Get shopping item response schema
class GetShoppingItemOutDTO(BaseModel):
    data: BaseShoppingListItem

    class Config:
        from_attributes = True

# Get shopping items response schema
class GetAllShoppingItemsDTO(BaseModel):
    data: list[BaseShoppingListItem]

    class Config:
        from_attributes = True


# Get all shopping lists filter params
class FoodSuggestionFilterParams(BaseModel):
    food_name: str = Field(..., description="Nom de l'aliment a rechercher")
