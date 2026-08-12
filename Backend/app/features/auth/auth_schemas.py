from typing import Optional
from pydantic import BaseModel, Field, EmailStr
from app.features.users.user_schemas import BaseUser

# Login request schema
class LoginDTO(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)
    fcm_token: Optional[str] = Field(None)
    
# User response schema 
class BaseUserDTO(BaseModel):
    user: BaseUser        
    access_token: str
    message: str    