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
        
async def add_job(func, job_id: str, trigger: str = None, args=None, kwargs=None, **trigger_kwargs):
    scheduler.add_job(
        func=func,
        trigger=trigger,
        id=job_id,
        args=args or [],
        kwargs=kwargs or {},
        coalesce=True,
        max_instances=1,
        **trigger_kwargs
    )

async def run_jobs():
    if scheduler.running:
        return
    
    await add_job(
        func=notifications_job,
        trigger="cron",
        day_of_week="fri",
        hour=23,
        job_id="shopping_list_remaining"
    )

    scheduler.start()
