from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from app.features.shopping_lists.models import ShoppingList

class ShoppingListRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_user_id(self, user_id: int) -> list[ShoppingList]:
        result = await self.session.execute(
            select(ShoppingList).where(ShoppingList.user_id == user_id)
        )
        return result.scalars().all()

    async def get_by_id(self, list_id: int) -> ShoppingList | None:
        result = await self.session.execute(
            select(ShoppingList).where(ShoppingList.id == list_id)
        )
        return result.scalar_one_or_none()

    async def get_by_id_and_user(self, list_id: int, user_id: int) -> ShoppingList | None:
        result = await self.session.execute(
            select(ShoppingList).where(
                and_(
                    ShoppingList.id == list_id,
                    ShoppingList.user_id == user_id
                )
            )
        )
        return result.scalar_one_or_none()

    async def get_by_week_and_user(self, week_number: int, user_id: int, year: int) -> ShoppingList | None:
        from sqlalchemy import extract
        result = await self.session.execute(
            select(ShoppingList).where(
                and_(
                    ShoppingList.week_number == week_number,
                    ShoppingList.user_id == user_id,
                    extract('year', ShoppingList.created_at) == year
                )
            )
        )
        return result.scalar_one_or_none()

    async def create(self, list_data: dict) -> ShoppingList:
        shopping_list = ShoppingList(**list_data)
        self.session.add(shopping_list)
        await self.session.commit()
        await self.session.refresh(shopping_list)
        return shopping_list

    async def update(self, list_id: int, update_data: dict) -> ShoppingList | None:
        shopping_list = await self.get_by_id(list_id)
        if shopping_list:
            for key, value in update_data.items():
                setattr(shopping_list, key, value)
            await self.session.commit()
            await self.session.refresh(shopping_list)
        return shopping_list

    async def delete(self, list_id: int) -> bool:
        shopping_list = await self.get_by_id(list_id)
        if shopping_list:
            await self.session.delete(shopping_list)
            await self.session.commit()
            return True
        return False