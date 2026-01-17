from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.features.categories.models import FoodCategory

class CategoryRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_all(self) -> list[FoodCategory]:
        result = await self.session.execute(select(FoodCategory))
        return result.scalars().all()

    async def get_by_id(self, category_id: int) -> FoodCategory | None:
        result = await self.session.execute(
            select(FoodCategory).where(FoodCategory.id == category_id)
        )
        return result.scalar_one_or_none()

    async def create(self, category_data: dict) -> FoodCategory:
        category = FoodCategory(**category_data)
        self.session.add(category)
        await self.session.commit()
        await self.session.refresh(category)
        return category

    async def delete(self, category_id: int) -> bool:
        category = await self.get_by_id(category_id)
        if category:
            await self.session.delete(category)
            await self.session.commit()
            return True
        return False