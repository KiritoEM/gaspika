from sqlalchemy.orm import contains_eager, joinedload
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.enums import UnitEnum
from app.models import Food, ShoppingList, ShoppingListItem

class ShoppingItemsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, list_id: int, food_id: int, price: float, person_number:int, quantity: float, unit: UnitEnum) -> ShoppingListItem:
        """Create new shopping item"""
        item = ShoppingListItem(
            shopping_list_id=list_id,
            food_id=food_id,
            recommanded_quantity=quantity,
            price=price,
            person_number=person_number,
            notes=None,
            unit=unit
        )
        self.db.add(item)
        await self.db.commit()
        await self.db.refresh(item)
        
        return item
    
    async def get_all_items(self, user_id: str, list_id: int) -> list[ShoppingListItem]:
        """Get all shopping items of an user"""
        query = select(ShoppingListItem).join(ShoppingList).where(
            ShoppingList.user_id == user_id
        ).where(ShoppingListItem.shopping_list_id == list_id)
                
        result = await self.db.execute(
            query.options(
                joinedload(ShoppingListItem.shopping_list),
                joinedload(ShoppingListItem.food).joinedload(Food.category)
            ).order_by(ShoppingListItem.created_at.desc())
        )
        
        return result.scalars().all()
