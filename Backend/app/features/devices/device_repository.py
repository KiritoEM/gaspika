from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import Device, User

class DeviceRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
        
    async def create(self, fcm_token: str, user_id: str):
        """Create new device"""
        device = Device(
            fcm_token=fcm_token,
            user_id=user_id,
        ) 
        
        self.db.add(device)
        await self.db.commit()
        
    async def get_by_fcm_token(self, fcm_token: str):
        """Find device by fcm_token"""
        device = await self.db.execute(
            select(Device)
            .where(
                Device.fcm_token == fcm_token
            )
        )
        
        return device.scalar_one_or_none()
    
    async def get_by_user_id(self, user_id: str) -> list[Device]:
        """Find device by fcm_token"""
        device = await self.db.execute(
            select(Device)
            .join(Device.user)
            .where(
                User.id == user_id
            )
        )
        
        return device.scalars().all() 

    async def delete_by_fcm_token(self, fcm_token):
        """Delete a device by fcm token"""
        device = await self.get_by_fcm_token(fcm_token)
        
        if device:
            await self.db.delete(device)
            await self.db.commit()
            
            return True
        
        return False