from fastapi import HTTPException 
from app.features.users.user_repository import UserRepository
from app.features.users.user_schemas import UserCreateDTO

class UserServices:
    def __init__(self, repot: UserRepository):
        self.repot = repot
        
    async def create_user(self, data: UserCreateDTO):
        if (await self.repot.get_user_by_email(data.model_dump()['email'])):
            raise HTTPException(status_code=409, detail="Un compte avec cet email existe deja.")
        
        return await self.repot.create(**data.model_dump())