from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ShoppingListItemBase(BaseModel):
    product_name: str
    estimated_quantity: float
    price: Optional[float] = None
    is_purchased: bool = False
    notes: Optional[str] = None
    storage_tips: Optional[str] = None
    category_id: Optional[int] = None
    actual_quantity: Optional[float] = None

class ShoppingListItemCreate(ShoppingListItemBase):
    shopping_list_id: int

class ShoppingListItemUpdate(BaseModel):
    estimated_quantity: Optional[float] = None
    price: Optional[float] = None
    is_purchased: Optional[bool] = None
    notes: Optional[str] = None
    actual_quantity: Optional[float] = None

class ShoppingListItemOut(ShoppingListItemBase):
    id: int
    shopping_list_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True