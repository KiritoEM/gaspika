from typing import Optional, Sequence
from sqlalchemy import extract, select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta, timezone
from app.features.shopping_lists.shopping_list_schemas import BaseShoppingList, UpdateShoppingListDTO
from app.core.enums import ShoppingListIntervalDateEnum, ShoppingListStatusEnum
from app.core.utils.pagination import paginate
from app.core.schemas import PageParams
from app.models import ShoppingList, ShoppingListItem
from sqlalchemy.orm import selectinload 

class ShoppingListRepository:
    def __init__(self, db: AsyncSession):
        self.db = db 
            
    async def get_all(self, user_id: str, page: int, limit: int,
                     status: Optional[ShoppingListStatusEnum] = None, 
                     intervalDate: Optional[ShoppingListIntervalDateEnum] = None
        ):
        """Get all lists with optional filters"""
        query = (
             select(ShoppingList)
            .options(selectinload(ShoppingList.items))
            .where(ShoppingList.user_id == user_id)
        )
        
        # Filter by status
        if status:
            query = query.where(ShoppingList.status == status)
        
        # Filter by date interval
        if intervalDate:
            now = datetime.now(timezone.utc) 
            
            if intervalDate == ShoppingListIntervalDateEnum.LAST_YEAR:
                start_date = datetime(now.year - 1, 1, 1, tzinfo=timezone.utc)
                end_date = datetime(now.year - 1, 12, 31, 23, 59, 59, tzinfo=timezone.utc)
                query = query.where(
                    and_(
                        ShoppingList.created_at >= start_date,
                        ShoppingList.created_at <= end_date
                    )
                )
            elif intervalDate == ShoppingListIntervalDateEnum.CURRENT_YEAR:
                start_date = datetime(now.year, 1, 1, tzinfo=timezone.utc)
                query = query.where(ShoppingList.created_at >= start_date)
                
            elif intervalDate == ShoppingListIntervalDateEnum.CURRENT_MONTH:
                start_date = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
                query = query.where(ShoppingList.created_at >= start_date)
                
            elif intervalDate == ShoppingListIntervalDateEnum.LAST_5_MONTH:
                start_date = now - timedelta(days=150)  # 5 months ~ 150 days
                query = query.where(ShoppingList.created_at >= start_date)
        
        # Order by date (most recent first)
        query = query.order_by(ShoppingList.created_at.desc())
                
        # Pagination
        return await paginate(self.db, PageParams(page=page, limit=limit), query, BaseShoppingList)
    
    async def get_by_id(self, list_id: int, user_id: str) -> ShoppingList:
        """Get shopping list by Id"""
        shopping_list = await self.db.execute(
            select(ShoppingList).where(
               and_(
                ShoppingList.user_id == user_id,
                ShoppingList.id == list_id
               )
            )
        )
        
        return shopping_list.scalars().first()
    
    
    async def get_by_item_id(self, item_id: int) -> ShoppingList:
        """Get shopping list by item id"""
        shopping_list = await self.db.execute(
            select(ShoppingList)
            .join(ShoppingList.items)
            .where(
               and_(
                ShoppingListItem.id == item_id
               )
            )
        )
        
        return shopping_list.scalars().first()
    
    async def create(self, week_number: int, user_id: str, name: str):
        """Create new shopping list"""
        new_shopping_list = ShoppingList(
            user_id=user_id,
            week_number=week_number,
            name=name
        )
        
        self.db.add(new_shopping_list)
        await self.db.commit()
        await self.db.refresh(new_shopping_list) 
        
    async def get_list_by_week(self, week_number: int, year: Optional[int], user_id: Optional[str]) -> Sequence[ShoppingList]:
        """Get List by specific week"""
        query = (
            select(ShoppingList)
            .where(
                ShoppingList.week_number == week_number
            )
        )    

        if user_id:
            query = (
                query
                .join(ShoppingList.user)
                .where(
                    ShoppingList.user_id == user_id,
                )
            )
        if year:
            query = query.where(extract('year', ShoppingList.created_at) == year)
            
        shopping_list = await self.db.execute(query)            
        
        return shopping_list.scalars()
    
    async def update_list(self, list_id: int, user_id: str, update_data: UpdateShoppingListDTO) -> Optional[ShoppingList]:
        """Update shopping list name or week_number"""
        shopping_list = await self.get_by_id(list_id, user_id)
        
        if shopping_list:
            shopping_list.name = update_data.name
            
            if update_data.week_number is not None:
                shopping_list.week_number = update_data.week_number
            
            shopping_list.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            await self.db.refresh(shopping_list)
            
            return shopping_list
        
        return None
    
    async def update_total_cost(self, list_id: int, cost: float) -> Optional[ShoppingList]:
        """Update total cost of an list"""
        result = await self.db.execute(select(ShoppingList).where(ShoppingList.id == list_id))
        shopping_list = result.scalar_one_or_none()

        if shopping_list:
            shopping_list.total_estimated_cost += cost
            shopping_list.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            await self.db.refresh(shopping_list)
            return shopping_list
        return None
    
    async def replace_total_cost(self, list_id: int, cost: float) -> Optional[ShoppingList]:
        """Replace total cost of an list"""
        result = await self.db.execute(select(ShoppingList).where(ShoppingList.id == list_id))
        shopping_list = result.scalar_one_or_none()

        if shopping_list:
            shopping_list.total_estimated_cost = cost
            shopping_list.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            await self.db.refresh(shopping_list)
            return shopping_list
        
        return None
    
     
    async def complete_list(self, list_id: int, user_id: str) -> Optional[ShoppingList]:
        """Change status of shopping list to complete"""
        shopping_list = await self.get_by_id(list_id, user_id)
        
        if shopping_list:
            shopping_list.status = ShoppingListStatusEnum.COMPLETED
            shopping_list.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            
            return shopping_list
            
        return None
    
    async def rollback_list_to_unfinished(self, list_id: int, user_id: str) -> Optional[ShoppingList]:
        """Change status of shopping list to unfinished"""
        shopping_list = await self.get_by_id(list_id, user_id)
        
        if shopping_list:
            shopping_list.status = ShoppingListStatusEnum.UNFINISHED
            shopping_list.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            
            return shopping_list
            
        return None

    async def delete_list(self, list_id: int, user_id: str) -> bool:
        """Delete shopping list and cascade items"""
        shopping_list = await self.get_by_id(list_id, user_id)
        
        if shopping_list:
            await self.db.delete(shopping_list)
            await self.db.commit()
            return True
        
        return False
