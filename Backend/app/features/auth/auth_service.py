from fastapi import HTTPException
from app.features.devices.device_repository import DeviceRepository
from app.core.utils.hashing import verify_hash
from app.features.auth.auth_schemas import LoginDTO
from app.features.users.user_repository import UserRepository

class AuthServices:
    def __init__(
        self, 
        user_repot: UserRepository,
        device_repot: DeviceRepository
    ): 
        self.user_repot = user_repot
        self.device_repot = device_repot
        
    async def login(self, data: LoginDTO):
        user = await self.user_repot.get_user_by_email(data.email)
        
        if not user:
            raise HTTPException(status_code=404, detail="Adresse email invalide ou inexistante.")
        
        if not verify_hash(data.password, user.password):
            raise HTTPException(status_code=401, detail="Mot de passe incorrect.")
        
        print(data)
        
        # create device with FCM token if not exist
        try:
            device = await self.device_repot.get_by_fcm_token(data.fcm_token)
        
            if (not device):
                await self.device_repot.create(data.fcm_token, (str(user.id)))
        except Exception as e:
            print(f"Impossible de créer le device: {str(e)}")
            raise HTTPException(status_code=500, detail="Impossible de créer le device")
        
        return user