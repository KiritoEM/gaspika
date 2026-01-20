from typing import Optional
from pydantic import BaseModel, EmailStr, Field

#Create User schema
class UserCreate(BaseModel):
    first_name: str
    last_name: str
    # phone_number: Optional[str] = None
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    

#User Out schema
class UserOut(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: EmailStr
    is_email_verified: bool
    is_deleted: bool
    created_at: str
    updated_at: str
