from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.schemas import PageParams
from app.core.utils.pagination import paginate
from app.features.notifications.notifications_schemas import BaseNotification, CreateNotificationSchema
from app.models import Notification, User

class NotificationsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
        
    async def get_all(self, user_id: str, page: int, limit: int):
        """Get all notifications of an user"""
        query = (
            select(Notification)
            .join(Notification.user)
            .where(User.id == user_id)
            .order_by(Notification.created_at.desc())
        )
        
        return await paginate(self.db, PageParams(page=page, limit=limit), query, BaseNotification)
    
    
    async def get_unread_notifications(self, user_id: str):
        """Get unread notifications of an user"""
        unread_notifications = await self.db.execute(
            select(Notification)
            .join(Notification.user)
            .where(
                and_(
                    User.id == user_id,
                    Notification.is_read == False
                )
            )
        )
        
        return unread_notifications.scalars().all()
    
    async def get_by_id(self, id: str) -> Notification | None:
        """Get notification by its id"""
        notification = await self.db.execute(
            select(Notification)
            .where(Notification.id == id)
        )
        
        return notification.scalars().first()
    
    async def get_unread_notifications_count(self, user_id) -> int:
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
        unread_notifications_count = await self.db.execute(query)
        
        return unread_notifications_count.scalar()
      
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

    async def mark_as_read(self, id: str):
        """Mark a notification as read"""
        notification = await self.get_by_id(id)
        
        if notification:
            notification.is_read = True
            
            await self.db.commit()
            await self.db.refresh(notification)
            
    async def delete(self, id: str) -> bool:
        """Delete a notification"""
        notification = await self.get_by_id(id)
        
        if notification:
            await self.db.delete(notification)
            await self.db.commit()
            
            return True
        
        return False