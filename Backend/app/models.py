from sqlalchemy import Column, BigInteger, Integer, String, Boolean, ForeignKey, Text, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class Preferences(Base):
    __tablename__ = "preferences"
    id = Column(BigInteger, primary_key=True, index=True)
    preference_type = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    users = relationship("User", back_populates="preferences")

class User(Base):
    __tablename__ = "user"
    id = Column(BigInteger, primary_key=True, index=True)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    phone_number = Column(String, nullable=True)
    household_size = Column(Integer, nullable=False, default=1)
    email = Column(String, unique=True, index=True, nullable=False)
    email_verified = Column(Boolean, default=False)
    password_hash = Column(String, nullable=False)
    preference_id = Column(BigInteger, ForeignKey("preferences.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    preferences = relationship("Preferences", back_populates="users")
    shopping_lists = relationship("ShoppingList", back_populates="user")

class FoodCategory(Base):
    __tablename__ = "food_category"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    icon_url = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    products = relationship("FoodProduct", back_populates="category")

class FoodProduct(Base):
    __tablename__ = "food_product"
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    storage_tips = Column(Text, nullable=True)
    default_shelf_life_c = Column(String, nullable=True)
    recommended_quan = Column(Integer, nullable=True)
    unit = Column(String, nullable=False, default="unit")
    image_url = Column(String, nullable=True)
    category_id = Column(BigInteger, ForeignKey("food_category.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    category = relationship("FoodCategory", back_populates="products")

class ShoppingList(Base):
    __tablename__ = "shopping_list"
    id = Column(BigInteger, primary_key=True, index=True)
    week_number = Column(Integer, nullable=False)
    name = Column(String, nullable=True)
    status = Column(String, nullable=True)
    total_estimated_cost = Column(Integer, nullable=True, default=0)
    user_id = Column(BigInteger, ForeignKey("user.id"), nullable=False)
    is_completed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="shopping_lists")
    items = relationship("ShoppingListItem", back_populates="shopping_list", cascade="all, delete-orphan")

class ShoppingListItem(Base):
    __tablename__ = "shopping_list_item"
    id = Column(BigInteger, primary_key=True, index=True)
    product_name = Column(String, nullable=False)
    shopping_list_id = Column(BigInteger, ForeignKey("shopping_list.id"), nullable=False)
    estimated_quantity = Column(Integer, nullable=False, default=1)
    price = Column(Integer, nullable=True, default=0)
    is_purchased = Column(Boolean, default=False)
    notes = Column(Text, nullable=True)
    storage_tips = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())  # Changé de Date à DateTime
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())  # Nouveau
    category_id = Column(BigInteger, ForeignKey("food_category.id"), nullable=True)

    shopping_list = relationship("ShoppingList", back_populates="items")
    category = relationship("FoodCategory")