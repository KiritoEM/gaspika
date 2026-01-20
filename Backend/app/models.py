from datetime import datetime, timezone
from typing import List, Optional
import uuid
from sqlalchemy import UUID, BigInteger, Float, ForeignKey, Integer, SmallInteger, String, Boolean, DateTime, Enum, Text, text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.enums import ShoppingListItemEnum, ShoppingListStatusEnum, UnitEnum
from app.core.database import Base

class User(Base):
    __tablename__ = "users" 
    
    id: Mapped[str] = mapped_column(UUID(as_uuid=True), primary_key=True, index=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    first_name: Mapped[str] = mapped_column(String(100), nullable=False)
    last_name: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    password: Mapped[str] = mapped_column(String(255), nullable=False)
    is_email_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    
    # Relations
    shopping_lists: Mapped[List["ShoppingList"]] = relationship(back_populates="user", cascade="all, delete-orphan", lazy="selectin")


class FoodCategory(Base):
    __tablename__ = "food_categories"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    
    # Relations
    foods: Mapped[List["Food"]] = relationship(back_populates="category", cascade="all, delete-orphan", lazy="selectin")


class Food(Base):
    __tablename__ = "foods"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    storage_tips: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    default_shelf_life_day: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    food_category_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("food_categories.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    # Relations
    category: Mapped["FoodCategory"] = relationship(back_populates="foods", lazy="selectin")
    shopping_items: Mapped[List["ShoppingListItem"]] = relationship(back_populates="food", cascade="all, delete-orphan", lazy="selectin")
    
class ShoppingListItem(Base):
    __tablename__ = "shopping_list_items"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    recommanded_quantity: Mapped[float] = mapped_column(Float, nullable=False)
    price: Mapped[float] = mapped_column(Float, nullable=False)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    person_number: Mapped[int] = mapped_column(Integer, nullable=False)
    status: Mapped[ShoppingListItemEnum] = mapped_column(Enum(ShoppingListItemEnum), nullable=False, default=ShoppingListItemEnum.UNPURCHASED)
    unit:Mapped[UnitEnum] = mapped_column(Enum(UnitEnum), nullable=False, default=UnitEnum.UNIT)
    shopping_list_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("shopping_lists.id"), nullable=False)
    food_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("foods.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    
    # Relations
    shopping_list: Mapped["ShoppingList"] = relationship(back_populates="items", lazy="selectin")
    food: Mapped["Food"] = relationship(back_populates="shopping_items", lazy="selectin")

class ShoppingList(Base):
    __tablename__ = "shopping_lists"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    week_number: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    total_estimated_cost: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    status: Mapped[ShoppingListStatusEnum] = mapped_column(Enum(ShoppingListStatusEnum), nullable=False, default=ShoppingListStatusEnum.UNFINISHED)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    
    # Relations
    user: Mapped["User"] = relationship(back_populates="shopping_lists", lazy="selectin")
    items: Mapped[List["ShoppingListItem"]] = relationship(back_populates="shopping_list", cascade="all, delete-orphan", lazy="selectin")   