from datetime import datetime, timezone
from typing import Optional
from sqlalchemy.orm import joinedload
from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.features.shopping_items.shopping_items_schemas import CreateShoppingItemDTO, UpdateShoppingItemDTO
from app.core.enums import ShoppingListItemEnum
from app.models import ShoppingList, ShoppingListItem

class ShoppingItemsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(
        self,
        list_id: int,
        user_id: str,
        item_data: CreateShoppingItemDTO
    ) -> ShoppingListItem:
        """Create new shopping item"""
        shopping_item = ShoppingListItem(
            food_name=item_data.food_name,
            recommended_quantity=item_data.quantity,
            price=item_data.price,
            person_number=item_data.person_number,
            notes=item_data.notes,
            unit=item_data.unit,
            default_shelf_life_day = item_data.default_shelf_life_day,
            food_category_id = item_data.food_category_id,
            storage_tips = item_data.storage_tips,
            shopping_list_id=list_id,
            user_id=user_id
        )
        
        self.db.add(shopping_item)
        await self.db.commit()
        
        return shopping_item
    
    async def get_all(self, list_id: int) -> list[ShoppingListItem]:
        """Get all shopping items of an user"""                
        all_items = await self.db.execute(
            select(ShoppingListItem)
            .join(ShoppingListItem.shopping_list)
            .where(ShoppingList.id == list_id)
            .order_by(ShoppingListItem.created_at.desc())
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
        )
        
        return all_items.scalars().all()
    
    async def get_by_id(self, item_id: int, user_id: str) -> Optional[ShoppingListItem] :
        """Get item by id"""
        shopping_item = await self.db.execute(
            select(ShoppingListItem)
            .join(ShoppingListItem.shopping_list)
            .where(
                and_(
                    ShoppingList.user_id == user_id,
                    ShoppingListItem.id == item_id
                )
            )
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
        )
        
        return shopping_item.scalar_one_or_none()
    
    async def get_items_count(self, user_id: str, list_id: int, status: Optional[str]) -> int :
        """Get shopping items count of an list"""   
        
        query = (
             select(func.coalesce(func.count(ShoppingListItem.id), 0))
            .join(ShoppingListItem.shopping_list)
            .where(
                and_(
                    ShoppingList.user_id == user_id,
                    ShoppingList.id == list_id,
                )
            )
        )
                
        if status:
            query = query.where(ShoppingListItem.status == status)
        
        items_count = await self.db.execute(query)     

        return items_count.scalar()
    
    async def get_items_of_list(self, user_id: str, list_id: int, status: Optional[str]) -> list[ShoppingListItem] :
        """Get shopping items count of an list"""   
        
        query = (
             select(ShoppingListItem)
            .join(ShoppingListItem.shopping_list)
            .where(
                and_(
                    ShoppingList.user_id == user_id,
                    ShoppingList.id == list_id,
                )
            )
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
        )
                
        if status:
            query = query.where(ShoppingListItem.status == status)
        
        shopping_items = await self.db.execute(query)     

        return shopping_items.scalars().all()
    
    
    async def search_by_food_name(self, name: str, user_id: str) -> list[ShoppingListItem] :
        """Get all items by food name in a list or global items or by item_id"""
        query = (
            select(ShoppingListItem)
            .join(ShoppingListItem.shopping_list)
            .where(ShoppingListItem.food_name
            .ilike(f"%{name}%"))
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
        )
        
        if user_id:
            query = query.where(ShoppingList.user_id == user_id)
                
        shopping_item = await self.db.execute(query)
        
        return shopping_item.scalars().all()
    
    async def get_total_price(self, user_id: str, list_id: int) -> float :
        """get total price of an items for a list"""
        total_price = await self.db.execute(
            select(func.coalesce(func.sum(ShoppingListItem.price * ShoppingListItem.recommended_quantity), 0))
            .join(ShoppingListItem.shopping_list)
            .where(
                and_(
                    ShoppingList.user_id == user_id,
                    ShoppingList.id == list_id
                )
           )
        )
        
        return total_price.scalar()
    
    async def complete_item(self, item_id: int, user_id: str) -> Optional[ShoppingListItem]:
        """Change status of shopping item to complete"""
        result = await self.db.execute(
            select(ShoppingListItem)
            .join(ShoppingListItem.shopping_list)
           .where(
                and_(
                    ShoppingList.user_id == user_id,
                    ShoppingListItem.id == item_id
                )
           )
        )
        
        shopping_item = result.scalar_one_or_none()
        
        if shopping_item:
            shopping_item.status = ShoppingListItemEnum.PURCHASED
            shopping_item.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            
            return shopping_item
            
        return None
    
    async def update(
        self, 
        item_id: int, 
        user_id: str, 
        list_id: int, 
        item_data: UpdateShoppingItemDTO
    ) -> Optional[ShoppingListItem] :
        """Update Shopping item"""
        result = await self.db.execute(
            select(ShoppingListItem)
            .join(ShoppingListItem.shopping_list)
            .where(
                and_(
                    ShoppingList.user_id == user_id,
                    ShoppingList.id == list_id,
                    ShoppingListItem.id == item_id
                )
           )
        )   
        
        shopping_item = result.scalar_one_or_none()
        
        # Update change field
        if shopping_item:
            for field, value in item_data.model_dump(exclude_unset=True).items():
                setattr(shopping_item, field, value)
            
            shopping_item.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            await self.db.refresh(shopping_item, ['category', 'image', 'shopping_list', 'user'])  

            return shopping_item
        
        return None
    
    async def delete(self, item_id: int, user_id: str, list_id: int) -> bool:
        """Delete shopping item"""
        result = await self.db.execute(
            select(ShoppingListItem)
            .join(ShoppingListItem.shopping_list)
            .where(
                and_(
                    ShoppingList.user_id == user_id,
                    ShoppingList.id == list_id,
                    ShoppingListItem.id == item_id
                )
            )
        )
        
        shopping_item = result.scalar_one_or_none()
        
        if shopping_item:
            await self.db.delete(shopping_item)
            await self.db.commit()
            
            return True
        
        return False