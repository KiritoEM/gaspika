from sqlalchemy.orm import Session
from fastapi import HTTPException 
from app.features.users.repository import UserRepository
from app.features.users.schemas import UserCreate

class UserServices:
    def __init__(self, repot: UserRepository):
        self.repot = repot
        
    def create_user(self, data: UserCreate):
        if (self.repot.get_user_by_email(data.model_dump()['email'])):
            raise HTTPException(status_code=409, detail="Un compte avec cet email existe deja.")
        
        return self.repot.create(**data.model_dump())