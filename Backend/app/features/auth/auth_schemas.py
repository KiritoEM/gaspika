from pydantic import BaseModel
from app.features.users.user_schemas import BaseUser

# Login request schema
class LoginDTO(BaseModel):
    email: str
    password: str
    
# User response schema 
class BaseUserDTO(BaseModel):
    user: BaseUser        
    access_token: str
    message: str    