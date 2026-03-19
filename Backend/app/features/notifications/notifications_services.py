from app.features.users.user_repository import UserRepository
from app.core.notification_push import send_android_notification
from app.features.devices.device_repository import DeviceRepository
from app.features.notifications.notifications_respository import NotificationsRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.core.date import get_week_number
from datetime import date, datetime
from app.features.notifications.notifications_schemas import CreateNotificationSchema

class NotificationsServices:
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
            await self._create_shopping_list_notif(user.id)
    
    async def _create_shopping_list_notif(self, user_id: str):
        """create notification for all lists of current week"""
        
        current_week = get_week_number(date.today())
        all_shopping_week_list = await self.shopping_list_repo.get_list_by_week(current_week, datetime.now().year, user_id)

        for shopping_list  in all_shopping_week_list:
            items_count = len(shopping_list.items or [])
            
            print(f"Envoie de la notification pour la liste: {shopping_list.name} |  user_id: {user_id}")
            
            if items_count == 0:
                continue
            else:                
                notification_body = (
                f"La semaine touche à sa fin… "
                f"Il reste encore {items_count} aliment{'s' if items_count > 1 else ''} "
                f"non acheté{'s' if items_count > 1 else ''} "
                f"dans votre liste « {shopping_list .name} »."
                )
                route = f"/shopping-list/{shopping_list.id}"

                notification_data = CreateNotificationSchema(
                    body=notification_body,
                    route=route
                )

                await self.notifications_repo.create(user_id, notification_data)

                # send notification push 
                devices = await self.device_repo.get_by_user_id(user_id)
                    
                for device in devices:
                    try:
                        await send_android_notification( 
                            fcm_token=device.fcm_token,
                            title="Des aliments non achetés en fin de semaine",
                            body=notification_body,
                            data={
                                    "route" : route
                            }
                        )
                    except Exception as e:
                            print(f"Notification échouée pour device {device.id}: {e}")
        
    
                            


