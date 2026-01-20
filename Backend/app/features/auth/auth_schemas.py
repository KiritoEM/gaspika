from pydantic import BaseModel
from app.features.users.user_schemas import UserOut

# Login request schema
class LoginDTO(BaseModel):
    email: str
    password: str
    
# User response schema 
class UserOutDTO(BaseModel):
    user: UserOut        
    access_token: str
    message: str    