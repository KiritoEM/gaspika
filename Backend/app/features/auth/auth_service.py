from fastapi import HTTPException
from app.features.devices.device_repository import DeviceRepository
from app.core.utils.hashing import verify_hash
from app.features.auth.auth_schemas import LoginDTO
from app.features.users.user_repository import UserRepository

class AuthServices:
    def __init__(
        self, 
        user_repo: UserRepository,
        device_repo: DeviceRepository
    ): 
        self.user_repo = user_repo
        self.device_repo = device_repo
        
    async def login(self, data: LoginDTO):
        user = await self.user_repo.get_user_by_email(data.email)
        
        if not user:
            raise HTTPException(status_code=404, detail="Adresse email invalide ou inexistante.")
        
        if not verify_hash(data.password, user.password):
            raise HTTPException(status_code=401, detail="Mot de passe incorrect.")
        
        # check if FCM token already exist
        existing_device = await self.device_repo.get_by_fcm_token(data.fcm_token)
        if existing_device:
            return user
                
        # create device with FCM token if not exist
        try:
            if data.fcm_token:
                await self.device_repo.create(data.fcm_token, (str(user.id)))
        except Exception as e:
            print(f"Impossible de créer le device: {str(e)}")
            raise HTTPException(status_code=500, detail="Impossible de créer le device")
        
        return user
