from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.features.users.repository import UserRepository
from app.features.users.schemas import UserCreate, UserUpdate, UserOut
from app.core.security import hash_password
from app.features.shopping_lists.models import ShoppingList

class UserService:
    def __init__(self, session: AsyncSession):
        self.repository = UserRepository(session)

    async def get_user_by_id(self, user_id: int) -> UserOut | None:
        user = await self.repository.get_by_id(user_id)
        return UserOut.model_validate(user) if user else None

    async def get_user_by_email(self, email: str) -> UserOut | None:
        user = await self.repository.get_by_email(email)
        return UserOut.model_validate(user) if user else None

    async def create_user(self, user_data: UserCreate) -> UserOut:
        # Vérifier si l'email existe déjà
        existing = await self.repository.get_by_email(user_data.email)
        if existing:
            raise ValueError("Email already registered")
        
        # Hasher le mot de passe
        user_dict = user_data.model_dump(exclude={"password"})
        user_dict["password_hash"] = hash_password(user_data.password)
        
        user = await self.repository.create(user_dict)
        return UserOut.model_validate(user)

    async def update_user(self, user_id: int, user_update: UserUpdate) -> UserOut:
        update_data = user_update.model_dump(exclude_unset=True)
        
        # Si le mot de passe est inclus, le hasher
        if "password" in update_data:
            update_data["password_hash"] = hash_password(update_data.pop("password"))
        
        user = await self.repository.update(user_id, update_data)
        if not user:
            raise ValueError("User not found")
        
        return UserOut.model_validate(user)

    async def get_user_profile(self, user_id: int) -> dict:
        user = await self.repository.get_by_id(user_id)
        if not user:
            raise ValueError("User not found")
        
        # Compter les listes de courses (exemple)
        # Note: Vous aurez besoin d'importer ShoppingList
        from sqlalchemy import select
        shopping_list_count = await self.session.scalar(
            select(func.count(ShoppingList.id)).where(ShoppingList.user_id == user_id)
        )
        
        return {
            "user": UserOut.model_validate(user),
            "shopping_list_count": shopping_list_count or 0,
            "total_spent": 0.0  # À calculer selon votre logique métier
        }