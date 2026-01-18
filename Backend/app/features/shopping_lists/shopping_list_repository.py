from typing import Optional
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta, timezone
from app.features.users.user_repository import UserRepository
from app.features.shopping_lists.shopping_list_schemas import ShoppingListOut
from app.core.enums import ShoppingListIntervalDateEnum
from app.core.utils.pagination import paginate
from app.core.schemas import PageParams
from app.models import ShoppingList

class ShoppingListRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
            
    async def get_all(self, user_id: str, page: int, limit: int,
                     status: Optional[str] = None, 
                     intervalDate: Optional[ShoppingListIntervalDateEnum] = None):
        """Get all lists with optional filters"""
        query = select(ShoppingList).where(ShoppingList.user_id == user_id)
        
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
        return await paginate(self.db, PageParams(page=page, size=limit), query, ShoppingListOut)
    
    async def get_by_id(self, list_id: int, user_id: int) -> ShoppingList:
        """Get shopping list by Id"""
        shopping_list = await self.db.execute(
            select(ShoppingList).where(
                ShoppingList.user_id == user_id,
                ShoppingList.id == list_id
            )
        )
        
        return shopping_list.scalar_one_or_none()
    
    async def create(self, week_number: int, user_id: str, name: str) -> ShoppingList:
        """Create new shopping list"""
        new_shopping_list = ShoppingList(user_id=user_id, week_number=week_number, name=name)
        
        self.db.add(new_shopping_list)
        await self.db.commit()
        await self.db.refresh(new_shopping_list) 
        return new_shopping_list
        
    async def get_list_by_week(self, week_number: int, user_id: str) -> Optional[ShoppingList]:
        """Get List by specific week"""
        shopping_list = await self.db.execute(select(ShoppingList).where(
            ShoppingList.user_id == user_id,
            ShoppingList.week_number == week_number
        ))
        
        return shopping_list.scalar_one_or_none()
    
    async def update_list(self, shopping_lists_id: int, user_id: str, 
                     name: Optional[str] = None, 
                     week_number: Optional[int] = None) -> Optional[ShoppingList]:
        """Update shopping list name or week_number"""
        result = await self.db.execute(select(ShoppingList).where(
            ShoppingList.id == shopping_lists_id,
            ShoppingList.user_id == user_id
        )).scalar_one_or_none()
        shopping_list = result.scalar_one_or_none()
        
        if shopping_list:
            if name is not None:
                shopping_list.name = name
            if week_number is not None:
                shopping_list.week_number = week_number
            
            shopping_list.updated_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            await self.db.refresh(shopping_list)
        
        return shopping_list
    
    async def update_total_cost(self, list_id: int, cost: float) -> Optional[ShoppingList]:
        result = await self.db.execute(select(ShoppingList).where(ShoppingList.id == list_id))
        shopping_list = result.scalar_one_or_none()

        if shopping_list:
            shopping_list.total_estimated_cost += cost
            shopping_list.updated_at = datetime.now(timezone.utc)
            await self.db.commit()
            await self.db.refresh(shopping_list)
            return shopping_list
        return None

    async def delete_list(self, shopping_lists_id: int, user_id: str) -> bool:
        """Delete shopping list and cascade items"""
        result = await self.db.execute(select(ShoppingList).where(
            ShoppingList.id == shopping_lists_id,
            ShoppingList.user_id == user_id
        )).scalar_one_or_none()
        shopping_list = result.scalar_one_or_none()
        
        if shopping_list:
            await self.db.delete(shopping_list)
            await self.db.commit()
            return True
        
        return False