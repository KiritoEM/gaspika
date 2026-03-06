from fastapi import HTTPException 
from app.features.devices.device_repository import DeviceRepository
from app.features.users.user_repository import UserRepository
from app.features.users.user_schemas import UserCreateDTO

class UserServices:
    def __init__(
        self, 
        user_repot: UserRepository,
        device_repot: DeviceRepository
    ):
        self.user_repot = user_repot
        self.device_repot = device_repot
        
    async def create_user(self, data: UserCreateDTO):
        if (await self.repot.get_user_by_email(data.email)):
            raise HTTPException(status_code=409, detail="Un compte avec cet email existe déja.")
        
        created_user = await self.repot.create(**data.model_dump())
        
        print(data)
          
        # create device with FCM token 
        try:
            await self.device_repot.create(data.fcm_token, str(created_user.id))
        except Exception as e:
            print(f"Impossible de créer le device: {str(e)}")
            raise HTTPException(status_code=500, detail="Impossible de créer le device")
            
        
        return created_user
    
    async def get_user_by_id(self, user_id: str):
        return await self.user_repot.get_user_by_id(user_id)