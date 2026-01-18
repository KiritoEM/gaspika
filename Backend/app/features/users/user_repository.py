from sqlalchemy import Select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import User
from app.core.utils.hashing import hash_string

class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    # Create new user
    async def create(self, email: str, first_name:str, last_name: str, password: str) -> User:
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
    
    # Find if email already exist
    async def get_user_by_email(self, email: str) -> User | None:
        user = await self.db.execute(Select(User).where(User.email == email))
        
        return user.scalar_one_or_none()
    
    # Find user by id
    async def get_user_by_id(self, user_id: str) -> User | None:
        user = await self.db.execute(Select(User).where(User.id == user_id))
        
        return user.scalar_one_or_none()
        
     