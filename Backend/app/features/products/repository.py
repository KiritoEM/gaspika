from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from app.features.products.models import FoodProduct

class ProductRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_all(self) -> list[FoodProduct]:
        result = await self.session.execute(select(FoodProduct))
        return result.scalars().all()

    async def get_by_id(self, product_id: int) -> FoodProduct | None:
        result = await self.session.execute(
            select(FoodProduct).where(FoodProduct.id == product_id)
        )
        return result.scalar_one_or_none()

    async def get_by_category(self, category_id: int) -> list[FoodProduct]:
        result = await self.session.execute(
            select(FoodProduct).where(FoodProduct.category_id == category_id)
        )
        return result.scalars().all()

    async def create(self, product_data: dict) -> FoodProduct:
        product = FoodProduct(**product_data)
        self.session.add(product)
        await self.session.commit()
        await self.session.refresh(product)
        return product

    async def update(self, product_id: int, update_data: dict) -> FoodProduct | None:
        product = await self.get_by_id(product_id)
        if product:
            for key, value in update_data.items():
                setattr(product, key, value)
            await self.session.commit()
            await self.session.refresh(product)
        return product

    async def delete(self, product_id: int) -> bool:
        product = await self.get_by_id(product_id)
        if product:
            await self.session.delete(product)
            await self.session.commit()
            return True
        return False