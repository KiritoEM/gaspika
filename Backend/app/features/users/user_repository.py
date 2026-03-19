from sqlalchemy import Select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import User
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
     