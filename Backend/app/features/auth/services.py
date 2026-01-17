from sqlalchemy.ext.asyncio import AsyncSession
from app.features.auth.repository import UserRepository
from app.features.auth.schemas import UserCreate, LoginRequest
from app.core.security import hash_password, verify_password, create_access_token

class AuthService:
    def __init__(self, session: AsyncSession):
        self.repository = UserRepository(session)

    async def register_user(self, user_data: UserCreate) -> dict:
        # Vérifier si l'email existe déjà
        existing_user = await self.repository.get_by_email(user_data.email)
        if existing_user:
            raise ValueError("Email already registered")
        
        # Créer l'utilisateur
        user_dict = user_data.model_dump(exclude={"password"})
        user_dict["password_hash"] = hash_password(user_data.password)
        
        user = await self.repository.create(user_dict)
        return user

    async def authenticate_user(self, login_data: LoginRequest) -> dict:
        user = await self.repository.get_by_email(login_data.email)
        if not user or not verify_password(login_data.password, user.password_hash):
            raise ValueError("Incorrect email or password")
        
        token = create_access_token(user.id)
        return {"access_token": token, "user": user}