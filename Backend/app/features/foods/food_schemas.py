from typing import Optional
from pydantic import BaseModel


class FoodOutDTO(BaseModel):
    id: int
    name: str
    food_category_id: int
    
    class Config:
        from_attributes = True