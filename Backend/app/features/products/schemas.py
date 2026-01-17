from pydantic import BaseModel
from typing import Optional
from app.core.enums import UnitEnum  # CORRIGÉ

class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    category_id: int
    unit_price: float
    unit: UnitEnum
    image_url: Optional[str] = None
    brand: Optional[str] = None
    weight_kg: Optional[float] = None
    is_organic: bool = False
    is_available: bool = True

class ProductOut(ProductBase):
    id: int
    category_name: Optional[str] = None

    class Config:
        from_attributes = True