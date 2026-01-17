from datetime import datetime
import enum
from sqlalchemy import Column, BigInteger, Float, ForeignKey, Integer, SmallInteger, String, Boolean, DateTime, Enum
from app.core.database import Base
from sqlalchemy.orm import relationship

class ShoppingListStatus(enum.Enum):
    COMPLETED = "COMPLETED"
    UNFINISHED = "UNFINISHED"
    ONGOING = "ONGOING"
    
class User(Base):
    __tablename__ = "user"
    id = Column(BigInteger, primary_key=True, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True)
    password = Column(String, nullable=False)
    is_email_verified = Column(Boolean, default=False)
    is_deleted = Column(Boolean, default=False) 
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)
    
    #relations
    shopping_lists = relationship("ShoppingList", back_populates="user", cascade="all, delete-orphan")

class ShoppingList(Base):
    __tablename__ = "shopping_list"
    id = Column(BigInteger, primary_key=True, index=True)
    week_number = Column(SmallInteger, nullable=False)
    name = Column(String, nullable=False)
    total_estimated_cost = Column(Float, nullable=False)
    status = Column(Enum(ShoppingListStatus), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)
    user_id = Column(Integer, ForeignKey("user.id", ondelete="CASCADE"))
    
    #relations
    user = relationship("User", back_populates="shopping_lists")