from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import APIRouter, Depends, Request
from app.features.notifications.notifications_schemas import BaseNotification, GetNotificationsFilterParams
from app.core.schemas import PagedResponseSchema
from app.features.users.user_repository import UserRepository
from app.features.devices.device_repository import DeviceRepository
from app.features.notifications.notifications_respository import NotificationsRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.features.notifications.notifications_service import NotificationsService
from app.core.database import db_session
from app.core.middlewares.auth_middleware import require_user

notification_router = APIRouter(prefix="/notifications", tags=["Notifications"], dependencies=[Depends(require_user)])

def get_notifications_service(db: AsyncSession = Depends(db_session)):
    shopping_list_repo = ShoppingListRepository(db)
    notifications_repo = NotificationsRepository(db)
    device_repo = DeviceRepository(db)
    user_repo = UserRepository(db)
    
    return NotificationsService(
        notifications_repo,
        shopping_list_repo,
        device_repo,
        user_repo
    )

@notification_router.get(
    "/",
    tags=["Notifications"],
    summary="Obtenir la liste des notifications d'un utilisateur",
    response_model=PagedResponseSchema[BaseNotification],
    responses={
        200: {"description": "Liste des notifications récupérée avec succés"}
    },
    status_code=200
)
async def get_notifications(
    request: Request,
    query: GetNotificationsFilterParams = Depends(),
    service: NotificationsService = Depends(get_notifications_service)
):
    return await service.get_all_notifications(request.state.user.id, query)