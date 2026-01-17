from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from app.features.shopping_items.models import ShoppingListItem

class ShoppingItemRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_list_id(self, list_id: int) -> list[ShoppingListItem]:
        result = await self.session.execute(
            select(ShoppingListItem).where(ShoppingListItem.shopping_list_id == list_id)
        )
        return result.scalars().all()

    async def get_by_id(self, item_id: int) -> ShoppingListItem | None:
        result = await self.session.execute(
            select(ShoppingListItem).where(ShoppingListItem.id == item_id)
        )
        return result.scalar_one_or_none()

    async def create(self, item_data: dict) -> ShoppingListItem:
        item = ShoppingListItem(**item_data)
        self.session.add(item)
        await self.session.commit()
        await self.session.refresh(item)
        return item

    async def update(self, item_id: int, update_data: dict) -> ShoppingListItem | None:
        item = await self.get_by_id(item_id)
        if item:
            for key, value in update_data.items():
                setattr(item, key, value)
            await self.session.commit()
            await self.session.refresh(item)
        return item

    async def delete(self, item_id: int) -> bool:
        item = await self.get_by_id(item_id)
        if item:
            await self.session.delete(item)
            await self.session.commit()
            return True
        return False

    async def count_unpurchased_by_list(self, list_id: int, category_id: int | None = None) -> int:
        query = select(ShoppingListItem).where(
            and_(
                ShoppingListItem.shopping_list_id == list_id,
                ShoppingListItem.is_purchased == False
            )
        )
        if category_id:
            query = query.where(ShoppingListItem.category_id == category_id)
        
        result = await self.session.execute(query)
        return len(result.scalars().all())