# Create Shopping list schema
from datetime import datetime
from typing import Optional
import uuid
from pydantic import BaseModel, Field
from app.core.enums import NotificationType

# Notification base schema
class BaseNotification(BaseModel):
    id: uuid.UUID
    body: str
    image: Optional[str] = Field(None)
    route: Optional[str] = Field(None)
    is_read: bool
    type: NotificationType
    created_at: datetime
    
    class Config:
        from_attributes = True

# Create notification schema
class CreateNotificationSchema(BaseModel):
    body: str
    image: Optional[str] = Field(None)
    route: Optional[str] = Field(None)
    type: Optional[NotificationType] = Field(None)
    
# Get unread notifications
class GetUnreadNotificationsCount(BaseModel):
    message: str
    count: int

    class Config:
        from_attributes = True
        
# Get notifications filter params
class GetNotificationsFilterParams(BaseModel):
    page: int = Field(1, ge=1, description="Page")
    limit: int = Field(10, ge=1, le=100, description="Taille page")
