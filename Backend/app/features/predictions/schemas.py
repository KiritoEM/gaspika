from pydantic import BaseModel
from typing import Optional

class QuantityPredictionRequest(BaseModel):
    category: str
    nb_persons: int
    duration_days: int
    qty_per_person_per_day: float
    meal_frequency: float
    unit_kg: bool = True

class QuantityPredictionResponse(BaseModel):
    quantity: float
    unit: str
    nb_persons: int
    duration_days: int