from pydantic import BaseModel
from app.features.users.schemas import UserOut

# Login request schema
class LoginDTO(BaseModel):
    email: str
    password: str
    
# User response schema 
class UserOutDTO(BaseModel):
    data: UserOut        
    access_token: str
    message: str    