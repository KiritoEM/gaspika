from typing import Optional, Sequence
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import FoodCategory

class CategoryRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_all(self) -> Sequence[FoodCategory]:
        """Get all categories"""
        result = await self.db.execute(select(FoodCategory))
        return result.scalars().all()
    
    async def create(self, name: str, ml_category: str, description: Optional[str] = None) -> FoodCategory:
        """Create new category"""
        category = FoodCategory(
            name=name,
            description=description,
            ml_category=ml_category
        )
        self.db.add(category)
        await self.db.commit()
        await self.db.refresh(category)
        return category
    
    async def update(self, category_id: int, name: Optional[str] = None, 
                    description: Optional[str] = None) -> Optional[FoodCategory]:
        """Update category"""
        result = await self.db.execute(
            select(FoodCategory).where(FoodCategory.id == category_id)
        )
        category = result.scalar_one_or_none()
        
        if category:
            if name is not None:
                category.name = name
            if description is not None:
                category.description = description
            
            await self.db.commit()
            await self.db.refresh(category)
        
        return category