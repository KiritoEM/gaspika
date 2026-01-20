from fastapi import HTTPException
from app.core.utils.hashing import verify_hash
from app.features.auth.auth_schemas import LoginDTO
from app.features.users.user_repository import UserRepository


class AuthServices:
    def __init__(self, repot: UserRepository):
        self.repot = repot
        
    async def login(self, data: LoginDTO):
        user = await self.repot.get_user_by_email(data.email)
        
        if not user:
            raise HTTPException(status_code=404, detail="Adresse email invalide ou inexistante.")
        
        if not verify_hash(data.password, user.password):
            raise HTTPException(status_code=401, detail="Mot de passe incorrect.")
        
        return user