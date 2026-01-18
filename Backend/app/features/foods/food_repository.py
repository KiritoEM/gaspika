from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import Food

class FoodRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_name(self, name: str) -> Optional[Food]:
        """Get food by name"""
        query = select(Food).where(Food.name.ilike(f"%{name}%"))
        result = await self.db.execute(query)
        
        return result.scalar_one_or_none()

    async def get_by_id(self, food_id: int) -> Optional[Food]:
        """Get food by id"""
        query = select(Food).where(Food.id == food_id)
        result = await self.db.execute(query)
        
        return result.scalar_one_or_none()

    async def create(self, name: str, default_shelf_life_day: int, category_id: int = 1) -> Food:
        """Create new food"""
        food = Food(
            name=name,
            food_category_id=category_id,
            storage_tips="À conserver au frais",
            default_shelf_life_day=default_shelf_life_day
        )
        self.db.add(food)
        await self.db.commit()
        await self.db.refresh(food)
        
        return food
