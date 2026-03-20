from datetime import datetime, timezone
from typing import List, Optional
import uuid
from sqlalchemy import UUID, BigInteger, Float, ForeignKey, Integer, SmallInteger, String, Boolean, DateTime, Enum, Text, text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.enums import NotificationType, ShoppingListItemEnum, ShoppingListStatusEnum, UnitEnum
from app.core.database import Base

class Image(Base):
    __tablename__="images"
    
    id: Mapped[str] = mapped_column(UUID(as_uuid=True), primary_key=True, index=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    filename: Mapped[str] = mapped_column(String(100), nullable=False)
    path: Mapped[str] = mapped_column(String(100), nullable=False)
    size: Mapped[int] = mapped_column(Integer, nullable=False)
    provider: Mapped[str] = mapped_column(String(50), nullable=False)
    file_id : Mapped[Optional[str]] = mapped_column(String(100), nullable=False)
    delete_url: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    shopping_list_item_id: Mapped[Optional[int]] = mapped_column(BigInteger, ForeignKey("shopping_list_items.id", ondelete="CASCADE"), nullable=True)
    
    # Relations
    shopping_item: Mapped["ShoppingListItem"] = relationship(back_populates="image")
    
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
    shopping_items: Mapped[List["ShoppingListItem"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    devices: Mapped[List["Device"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    notifications: Mapped[List["Notification"]] = relationship(back_populates="user", cascade="all, delete-orphan")


class FoodCategory(Base):
    __tablename__ = "food_categories"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False, unique=True)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    ml_category: Mapped[str] = mapped_column(String(100))
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
    items: Mapped[List["ShoppingListItem"]] = relationship(back_populates="category", lazy="selectin")

    
class ShoppingListItem(Base):
    __tablename__ = "shopping_list_items"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    food_name: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    storage_tips: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    default_shelf_life_day: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    recommended_quantity: Mapped[float] = mapped_column(Float, nullable=False)
    unit: Mapped[UnitEnum] = mapped_column(Enum(UnitEnum), nullable=False, default=UnitEnum.UNIT)
    price: Mapped[float] = mapped_column(Float, nullable=False)
    person_number: Mapped[int] = mapped_column(Integer, nullable=False)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    status: Mapped[ShoppingListItemEnum] = mapped_column(Enum(ShoppingListItemEnum), nullable=False, default=ShoppingListItemEnum.UNPURCHASED)
    
    # Foreign Keys
    shopping_list_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("shopping_lists.id", ondelete="CASCADE"), nullable=False)
    food_category_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("food_categories.id"), nullable=False)
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
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
    shopping_list: Mapped["ShoppingList"] = relationship(back_populates="items", lazy="joined")
    category: Mapped["FoodCategory"] = relationship(back_populates="items", lazy="joined")
    user: Mapped["User"] = relationship(back_populates="shopping_items", lazy="joined")
    image: Mapped[Optional["Image"]] = relationship(
        back_populates="shopping_item", 
        cascade="all, delete-orphan", 
        uselist=False,
        lazy="joined"
    )

class ShoppingList(Base):
    __tablename__ = "shopping_lists"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    week_number: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    total_estimated_cost: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    status: Mapped[ShoppingListStatusEnum] = mapped_column(Enum(ShoppingListStatusEnum), nullable=False, default=ShoppingListStatusEnum.UNFINISHED)
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
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
    user: Mapped["User"] = relationship(back_populates="shopping_lists", lazy="joined")
    items: Mapped[List["ShoppingListItem"]] = relationship(back_populates="shopping_list", cascade="all, delete-orphan", lazy="selectin")
    
    
class Device(Base):
    __tablename__ = "devices"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    fcm_token: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    device_type: Mapped[str] = mapped_column(String(200), default="android")
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
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
    user: Mapped["User"] = relationship(back_populates="devices")
    
    
class Notification(Base):
    __tablename__ = "notifications" 
    
    id: Mapped[str] = mapped_column(UUID(as_uuid=True), primary_key=True, index=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    body: Mapped[str] = mapped_column(Text, nullable=False)
    image: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    route: Mapped[Optional[str]] = mapped_column(String(255), nullable=True) 
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    type: Mapped[NotificationType] = mapped_column(Enum(NotificationType), nullable=False, default=NotificationType.LIST_EXPIRATION)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    
    # Relations
    user: Mapped["User"] = relationship(back_populates="notifications")
