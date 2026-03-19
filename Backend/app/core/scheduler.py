from apscheduler.schedulers.asyncio import AsyncIOScheduler
from app.core.database import AsyncSessionLocal
from app.features.notifications.notifications_services import NotificationsServices
from app.features.notifications.notifications_respository import NotificationsRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.features.devices.device_repository import DeviceRepository
from app.features.users.user_repository import UserRepository

scheduler = AsyncIOScheduler()

async def notifications_job():
    async with AsyncSessionLocal() as db:
        notifications_repo = NotificationsRepository(db)
        shopping_list_repo = ShoppingListRepository(db)
        device_repo = DeviceRepository(db)
        user_repo = UserRepository(db)

        notifications_service = NotificationsServices(
            notifications_repo,
            shopping_list_repo,
            device_repo,
            user_repo
        )

        await notifications_service.check_all_shopping_list()

def run_jobs():
    if scheduler.running:
        return

    scheduler.add_job(
        notifications_job,
        trigger="interval",
        day_of_week="fri",
        hour=23
        id="shopping_list_remaining",
        coalesce=True,
        max_instances=1
    )

    scheduler.start()
