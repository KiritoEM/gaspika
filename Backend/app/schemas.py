from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List

# --- Preferences ---
class PreferencesBase(BaseModel):
    preference_type: str

class PreferencesOut(PreferencesBase):
    id: int
    class Config:
        from_attributes = True

# --- User ---
class UserCreate(BaseModel):
    first_name: str
    last_name: str
    phone_number: Optional[str] = None
    household_size: int = Field(ge=1)
    email: EmailStr
    password: str
    preference_id: Optional[int] = None

class UserOut(BaseModel):
    id: int
    first_name: str
    last_name: str
    phone_number: Optional[str] = None
    household_size: int
    email: EmailStr
    email_verified: bool
    preference_id: Optional[int] = None
    class Config:
        from_attributes = True

class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"

# --- Category ---
class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None

class CategoryOut(CategoryBase):
    id: int
    class Config:
        from_attributes = True

# --- Product ---
class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    storage_tips: Optional[str] = None
    default_shelf_life_c: Optional[str] = None
    recommended_quan: Optional[int] = None
    unit: str
    image_url: Optional[str] = None
    category_id: int

class ProductOut(ProductBase):
    id: int
    category: Optional[CategoryOut] = None
    class Config:
        from_attributes = True

# --- Shopping List Item ---
class ShoppingListItemBase(BaseModel):
    product_name: str
    estimated_quantity: int
    price: Optional[int] = 0
    is_purchased: bool = False
    notes: Optional[str] = None
    storage_tips: Optional[str] = None
    category_id: Optional[int] = None

class ShoppingListItemOut(ShoppingListItemBase):
    id: int
    class Config:
        from_attributes = True

# --- Shopping List ---
class ShoppingListBase(BaseModel):
    week_number: int
    name: Optional[str] = None

class ShoppingListOut(ShoppingListBase):
    id: int
    status: Optional[str] = None
    total_estimated_cost: Optional[int] = 0
    is_completed: bool
    items: List[ShoppingListItemOut] = []
    class Config:
        from_attributes = True