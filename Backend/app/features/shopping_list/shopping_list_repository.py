from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta
from app.features.shopping_list.shopping_list_schemas import ShoppingListOutDTO
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
        query = query.order_by(ShoppingList.created_at.desc())
        
        # Filter by status
        if status:
            query = query.where(ShoppingList.status == status)
        
        # Filter by date interval
        if intervalDate:
            now = datetime.utcnow()
            match intervalDate:
                case ShoppingListIntervalDateEnum.LAST_YEAR:
                    start_date = datetime(now.year - 1, 1, 1)
                    end_date = datetime(now.year - 1, 12, 31, 23, 59, 59)
                    query = query.where(
                        ShoppingList.created_at >= start_date,
                        ShoppingList.created_at <= end_date
                    )
                case ShoppingListIntervalDateEnum.CURRENT_YEAR:
                    start_date = datetime(now.year, 1, 1)
                    query = query.where(ShoppingList.created_at >= start_date)
                case ShoppingListIntervalDateEnum.CURRENT_MONTH:
                    start_date = now.replace(day=1)
                    query = query.where(ShoppingList.created_at >= start_date)
                case ShoppingListIntervalDateEnum.LAST_5_MONTH:
                    start_date = now - timedelta(days=5*30)
                    query = query.where(ShoppingList.created_at >= start_date)
        
        # Pagination en dernier
        return await paginate(self.db, PageParams(page=page, size=limit), query, ShoppingListOutDTO)
