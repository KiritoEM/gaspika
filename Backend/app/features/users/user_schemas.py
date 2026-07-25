from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional
from uuid import UUID

# Create User schema
class UserCreateDTO(BaseModel):
    first_name: str 
    last_name: str
    email: EmailStr
    password: str = Field(min_length=8)

# Get User schema
class BaseUser(BaseModel):
    id: UUID
    first_name: str
    last_name: str
    email: EmailStr
    is_email_verified: bool
    is_deleted: bool
    created_at: datetime 
    updated_at: datetime
    
    class Config:
        from_attributes = True
        

# Get user schema
class GetUserDTO(BaseModel):
    data: BaseUser

    class Config:
        from_attributes = True
        
# Logout schema
class LogoutDTO(BaseModel):
    fcm_token: str

# Update user schema
class UpdateUserDTO(BaseModel):
    first_name: Optional[str] = Field(None, min_length=1, max_length=100)
    last_name: Optional[str] = Field(None, min_length=1, max_length=100)
    email: Optional[EmailStr] = Field(None)

# Update user response schema
class UpdateUserOutDTO(BaseModel):
    data: BaseUser
    message: str

    class Config:
        from_attributes = True

# Change password schema
class ChangePasswordDTO(BaseModel):
    current_password: str
    new_password: str = Field(min_length=8)

# Notification preference base schema
class BaseNotificationPreference(BaseModel):
    push_enabled: bool
    food_expiration_enabled: bool
    list_expiration_enabled: bool

    class Config:
        from_attributes = True

# Get notification preference schema
class GetNotificationPreferenceDTO(BaseModel):
    data: BaseNotificationPreference

    class Config:
        from_attributes = True

# Update notification preference schema
class UpdateNotificationPreferenceDTO(BaseModel):
    push_enabled: Optional[bool] = Field(None)
    food_expiration_enabled: Optional[bool] = Field(None)
    list_expiration_enabled: Optional[bool] = Field(None)

# Delete account schema
class DeleteAccountDTO(BaseModel):
    password: str
    fcm_token: Optional[str] = Field(None)

# Simple message response schema
class MessageResponse(BaseModel):
    message: str

