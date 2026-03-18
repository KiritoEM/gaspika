# Create Shopping list schema
from typing import Optional
from pydantic import BaseModel, Field
from app.core.enums import NotificationType

# Create notification schema
class CreateNotificationSchema(BaseModel):
    body: str
    image: Optional[str] = Field(None)
    route: Optional[str] = Field(None)
    type: Optional[NotificationType] = Field(None)
