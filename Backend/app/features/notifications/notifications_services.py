from app.features.notifications.notifications_respository import NotificationsRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.core.date import get_week_number
from datetime import date, datetime
from app.features.notifications.notifications_schemas import CreateNotificationSchema

class NotificationsServices:
    def __init__(
        self, 
        notifications_repo: NotificationsRepository,
        shopping_list_repo: ShoppingListRepository
    ):
      self.notifications_repo = notifications_repo
      self.shopping_list_repo = shopping_list_repo
 
    async def check_all_shopping_list(self):
        current_week = get_week_number(date.today())
        all_shopping_week_list = await self.shopping_list_repo.get_list_by_week(current_week, datetime.now().year)

        # create notification for all list of current week
        for list in all_shopping_week_list:
            if not hasattr(list, 'items'):
                continue
            else:
                items_count = len(list.items)

                notification_data = CreateNotificationSchema(
                    body=f"""
                        Il reste encore des aliments dans votre liste : {list.name}
                    """,
                    route="/shopping"
                )

                if items_count > 0:
                    await self.notifications_repo.create(
                        body=
                    )

                

