from sqlalchemy.ext.asyncio import AsyncSession
from app.features.notifications.notifications_schemas import CreateNotificationSchema
from app.models import Notification

class NotificationsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
      
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
