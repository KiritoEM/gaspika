from datetime import datetime, timezone
from typing import Optional
from sqlalchemy.orm import joinedload
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.enums import ShoppingListItemEnum, UnitEnum
from app.models import Food, ShoppingList, ShoppingListItem

class ShoppingItemsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(
        self,
        list_id: int, 
        food_id: int, 
        price: float, 
        person_number:int,
        quantity: float, 
        unit: UnitEnum
    ) -> ShoppingListItem:
        """Create new shopping item"""
        shopping_item = ShoppingListItem(
            shopping_list_id=list_id,
            food_id=food_id,
            recommanded_quantity=quantity,
            price=price,
            person_number=person_number,
            notes=None,
            unit=unit
        )
        self.db.add(shopping_item)
        await self.db.commit()
        await self.db.refresh(shopping_item)
        
        return shopping_item
    
    async def get_all_items(self, user_id: str, list_id: int) -> list[ShoppingListItem]:
        """Get all shopping items of an user"""
        query = select(ShoppingListItem).join(ShoppingList).where(
            ShoppingList.user_id == user_id
        ).where(ShoppingListItem.shopping_list_id == list_id)
                
        all_items = await self.db.execute(
            query.options(
                joinedload(ShoppingListItem.shopping_list),
                joinedload(ShoppingListItem.food).joinedload(Food.category)
            ).order_by(ShoppingListItem.created_at.desc())
        )
        
        return all_items.scalars().all()
    
    async def get_by_id(self, item_id: int, user_id: str, list_id: int) -> Optional[ShoppingListItem] :
        """Get item by id"""
        shopping_item = await self.db.execute(select(ShoppingListItem)
        .where(ShoppingList.user_id == user_id)
        .where(ShoppingListItem.id == item_id)
        .where((ShoppingListItem.shopping_list_id == list_id)))
        
        return shopping_item.scalar_one_or_none()
    
    async def complete_item(self, item_id: int, user_id: str, list_id: int) -> Optional[ShoppingListItem]:
        """Change status of shopping item to complete"""
        result = await self.db.execute(select(ShoppingListItem)
        .where(ShoppingList.user_id == user_id)
        .where(ShoppingListItem.id == item_id)
        .where((ShoppingListItem.shopping_list_id == list_id)))
        
        shopping_item = result.scalar_one_or_none()
        
        if shopping_item:
            shopping_item.status = ShoppingListItemEnum.PURCHASED
            shopping_item.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            await self.db.refresh(shopping_item)
            
            return shopping_item
            
        return None
    
    async def update(
        self, 
        item_id: int, 
        user_id: str, 
        list_id: int, 
        price: Optional[str], 
        notes: Optional[str],
        unit: UnitEnum
    ) -> Optional[ShoppingListItem] :
        """Update Shopping item"""
        result = await self.db.execute(select(ShoppingListItem)
        .where(ShoppingList.user_id == user_id)
        .where(ShoppingListItem.id == item_id)
        .where((ShoppingListItem.shopping_list_id == list_id)))
        
        shopping_item = result.scalar_one_or_none()
        
        if shopping_item:
            if price:
                shopping_item.price = price
            if notes:
                shopping_item.notes = notes
            if unit:
                shopping_item.unit = unit
            
            return shopping_item
        
        return None