from datetime import datetime, timezone
from sqlalchemy import Select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.features.users.user_schemas import UpdateUserDTO
from app.models import Device, Image, Notification, ShoppingList, ShoppingListItem, User
from app.core.utils.hashing import hash_string
from typing import Optional, Sequence

class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create(self, email: str, first_name:str, last_name: str, password: str) -> User:
        """Create new user"""
        user = User(
            first_name = first_name,    
            last_name = last_name,
            email = email,
            password= hash_string(password)  
        )
        
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        
        return user
    
    async def get_all(self) -> Sequence[User]:
        """Get all users"""
        users = await self.db.execute(Select(User))
        
        return users.scalars()
    
    async def get_user_by_email(self, email: str) -> Optional[User]:
        """Find if email already exist"""
        user = await self.db.execute(Select(User).where(User.email == email))
        
        return user.scalars().first()
    
    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        """Find user by id"""
        user = await self.db.execute(Select(User).where(User.id == user_id))

        return user.scalars().first()

    async def update_user(self, user_id: str, update_data: UpdateUserDTO) -> Optional[User]:
        """Update user first_name, last_name or email"""
        user = await self.get_user_by_id(user_id)

        if user:
            fields = update_data.model_dump(exclude_unset=True, exclude_none=True)

            if "email" in fields and fields["email"] != user.email:
                user.is_email_verified = False

            for field, value in fields.items():
                setattr(user, field, value)

            user.updated_at = datetime.now(timezone.utc)

            await self.db.commit()
            await self.db.refresh(user)

            return user

        return None

    async def update_password(self, user_id: str, new_password: str) -> Optional[User]:
        """Replace the password of an user"""
        user = await self.get_user_by_id(user_id)

        if user:
            user.password = hash_string(new_password)
            user.updated_at = datetime.now(timezone.utc)

            await self.db.commit()
            await self.db.refresh(user)

            return user

        return None

    async def soft_delete(self, user_id: str) -> bool:
        """Mark an user as deleted"""
        user = await self.get_user_by_id(user_id)

        if user:
            user.is_deleted = True
            user.updated_at = datetime.now(timezone.utc)

            await self.db.commit()

            return True

        return False

    async def get_image_delete_urls(self, user_id: str) -> Sequence[str]:
        """Get delete urls of user images"""
        result = await self.db.execute(
            Select(Image.delete_url)
            .join(Image.shopping_item)
            .where(
                ShoppingListItem.user_id == user_id,
                Image.delete_url.is_not(None)
            )
        )

        return result.scalars().all()

    async def purge_user_data(self, user_id: str) -> None:
        """Delete all personal data of an user"""
        await self.db.execute(delete(Notification).where(Notification.user_id == user_id))
        await self.db.execute(delete(Device).where(Device.user_id == user_id))
        await self.db.execute(delete(ShoppingListItem).where(ShoppingListItem.user_id == user_id))
        await self.db.execute(delete(ShoppingList).where(ShoppingList.user_id == user_id))

        await self.db.commit()
