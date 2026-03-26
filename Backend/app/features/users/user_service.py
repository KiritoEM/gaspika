from fastapi import HTTPException 
from app.features.users.user_repository import UserRepository
from app.features.users.user_schemas import UserCreateDTO

class UserServices:
    def __init__(
        self, 
        user_repo: UserRepository,
    ):
        self.user_repo = user_repo
        
    async def create_user(self, data: UserCreateDTO):
        if (await self.user_repo.get_user_by_email(data.email)):
            raise HTTPException(status_code=409, detail="Un compte avec cet email existe déja.")
        
        created_user = await self.user_repo.create(**data.model_dump())
                  
        # create device with FCM token 
        # try:
        #     await self.device_repo.create(data.fcm_token, str(created_user.id))
        # except Exception as e:
        #     print(f"Impossible de créer le device: {str(e)}")
        #     raise HTTPException(status_code=500, detail="Impossible de créer le device")
            
        
        return created_user
    
    async def get_user_by_id(self, user_id: str):
        return await self.user_repo.get_user_by_id(user_id)
