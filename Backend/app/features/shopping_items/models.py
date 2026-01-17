from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.core.database import Base

class ShoppingListItem(Base):
    __tablename__ = "shopping_list_items"

    id = Column(Integer, primary_key=True, index=True)
    product_name = Column(String, nullable=False)
    shopping_list_id = Column(Integer, ForeignKey("shopping_lists.id"), nullable=False)
    estimated_quantity = Column(Float, nullable=False)
    price = Column(Float, nullable=True)
    is_purchased = Column(Boolean, default=False)
    notes = Column(String, nullable=True)
    storage_tips = Column(String, nullable=True)
    category_id = Column(Integer, ForeignKey("food_categories.id"), nullable=True)
    actual_quantity = Column(Float, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow, nullable=True)
    
    # Relations
    shopping_list = relationship("ShoppingList", back_populates="items")
    category = relationship("FoodCategory")