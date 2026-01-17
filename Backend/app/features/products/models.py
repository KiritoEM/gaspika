from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.core.database import Base  # CORRIGÉ
from app.core.enums import UnitEnum  # CORRIGÉ

class FoodProduct(Base):
    __tablename__ = "food_products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    description = Column(String, nullable=True)
    category_id = Column(Integer, ForeignKey("food_categories.id"), nullable=False)
    unit_price = Column(Float, nullable=False)
    unit = Column(Enum(UnitEnum), nullable=False)
    image_url = Column(String, nullable=True)
    brand = Column(String, nullable=True)
    weight_kg = Column(Float, nullable=True)
    is_organic = Column(Boolean, default=False)
    is_available = Column(Boolean, default=True)
    
    # Relations
    category = relationship("FoodCategory", back_populates="products")