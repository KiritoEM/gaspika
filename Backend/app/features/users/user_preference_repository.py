from datetime import datetime, timezone
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.features.users.user_schemas import UpdateNotificationPreferenceDTO
from app.models import NotificationPreference
from typing import Optional

class UserPreferenceRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_user_id(self, user_id: str) -> Optional[NotificationPreference]:
        """Find notification preferences of an user"""
        preference = await self.db.execute(
            select(NotificationPreference)
            .where(NotificationPreference.user_id == user_id)
        )

        return preference.scalars().first()

    async def get_or_create(self, user_id: str) -> NotificationPreference:
        """Get notification preferences or create them"""
        preference = await self.get_by_user_id(user_id)

        if preference:
            return preference

        preference = NotificationPreference(user_id=user_id)

        self.db.add(preference)
        await self.db.commit()
        await self.db.refresh(preference)

        return preference

    async def update(self, user_id: str, update_data: UpdateNotificationPreferenceDTO) -> Optional[NotificationPreference]:
        """Update notification preferences of an user"""
        preference = await self.get_or_create(user_id)

        if preference:
            fields = update_data.model_dump(exclude_unset=True, exclude_none=True)

            for field, value in fields.items():
                setattr(preference, field, value)

            preference.updated_at = datetime.now(timezone.utc)

            await self.db.commit()
            await self.db.refresh(preference)

            return preference

        return None
