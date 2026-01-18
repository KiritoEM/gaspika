from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from uuid import UUID

class UserCreateDTO(BaseModel):
    first_name: str 
    last_name: str
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

class UserOut(BaseModel):
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
