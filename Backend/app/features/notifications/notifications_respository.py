from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.schemas import PageParams
from app.core.utils.pagination import paginate
from app.features.notifications.notifications_schemas import BaseNotification, CreateNotificationSchema
from app.models import Notification, User

class NotificationsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
        
    async def get_all(self, user_id: str, page: int, limit: int,):
        """Get notifications of an user"""
        query = (
            select(Notification)
            .join(Notification.user)
            .where(User.id == user_id)
        )
        
        return await paginate(self.db, PageParams(page=page, limit=limit), query, BaseNotification)
    
    async def get_unread_notifications_count(self, user_id):
        """Get unread notifications count"""
        query = (
            select(func.count())
            .select_from(Notification)
            .join(Notification.user)
            .where(and_(
                User.id == user_id,
                Notification.is_read == False
                
            ))
        )
        result = await self.db.execute(query)
        
        return result.scalar()
      
    async def create(self, user_id: str, data: CreateNotificationSchema):
        """Create notification"""
        new_notification = Notification(
            body=data.body,
            image=data.image,
            route=data.route,
            type=data.type,
            user_id=user_id
        )
        
        self.db.add(new_notification)
        await self.db.commit()
        await self.db.refresh(new_notification)
