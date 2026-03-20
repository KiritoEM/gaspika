from typing import Optional

from app.core.enums import NotificationType
from app.features.users.user_repository import UserRepository
from app.core.notification_push import send_android_notification
from app.features.devices.device_repository import DeviceRepository
from app.features.notifications.notifications_respository import NotificationsRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.core.date import get_week_number
from datetime import date, datetime
from app.features.notifications.notifications_schemas import CreateNotificationSchema, GetNotificationsFilterParams

class NotificationsService:
    def __init__(
        self, 
        notifications_repo: NotificationsRepository,
        shopping_list_repo: ShoppingListRepository,
        device_repo: DeviceRepository,
        user_repo: UserRepository
    ):
      self.notifications_repo = notifications_repo
      self.shopping_list_repo = shopping_list_repo
      self.device_repo = device_repo
      self.user_repo = user_repo 
      
    async def check_all_shopping_list(self):
        all_users = await self.user_repo.get_all()
        
        for user in all_users:
            await self._create_shopping_list_remaining_notif(user.id)
            
    async def check_near_expiry_food(
        self,
        user_id: str,
        food_name: str,
        shopping_item_id: int,
        food_image: Optional[str]
    ):
        body = (
            f"L’aliment «{food_name}» arrive bientôt à expiration. "
            f"Pensez à le consommer rapidement."
        )
        
        route = f"/shopping-list-items/{shopping_item_id}"

        await self._send_notification(
            user_id=user_id,
            title="Aliment proche de péremption",
            body=body,
            route=route,
            type=NotificationType.FOOD_EXPIRATION,
            image=food_image
        )

    async def get_all_notifications(self, user_id: str, query: GetNotificationsFilterParams):
        return await self.notifications_repo.get_all(user_id, query.page, query.limit)
    
    async def get_unread_notifications_count(self, user_id: str):
        return await self.notifications_repo.get_unread_notifications_count(user_id)
    
    async def mark_all_as_read(self, user_id: str):
        notifications =  await self.notifications_repo.get_unread_notifications(user_id)
        
        for notif in notifications:
            await self.notifications_repo.mark_as_read(notif.id)
            
    
    async def delete(self, notification_id: str):
        return await self.delete(notification_id)
    
    async def _create_shopping_list_remaining_notif(self, user_id: str):
        current_week = get_week_number(date.today())
        
        current_list = await self.shopping_list_repo.get_list_by_week(
            week_number=current_week,
            year=datetime.now().year,
            user_id=user_id
        )

        items_count = len(current_list.items or [])

        if items_count == 0:
            return

        body = (
            f"La semaine touche à sa fin… "
            f"Il reste encore {items_count} aliment{'s' if items_count > 1 else ''} "
            f"non acheté{'s' if items_count > 1 else ''} "
            f"dans votre liste « {current_list.name} »."
        )

        route = f"/shopping-list/{current_list.id}?name={current_list.name}&week={current_list.week_number}" 

        await self._send_notification(
            user_id=user_id,
            title="Des aliments non achetés en fin de semaine",
            body=body,
            route=route,
            type=NotificationType.LIST_EXPIRATION
        )
                            
    async def _send_notification(
        self,
        user_id: str,
        title: str,
        body: str,
        route: str,
        type: Optional[NotificationType],
        image: Optional[str]
    ):
        notification_data = CreateNotificationSchema(
            body=body,
            route=route,
            type=type,
            image=image
        )

        # Save notification
        await self.notifications_repo.create(user_id, notification_data)

        # Push notification
        devices = await self.device_repo.get_by_user_id(user_id)
        
        if len(devices) == 0:
            return

        for device in devices:
            try:
                await send_android_notification(
                    fcm_token=device.fcm_token,
                    title=title,
                    body=body,
                    data={"route": route}
                )
            except Exception as e:
                print(f"Notification failed for device {device.id}: {e}")



