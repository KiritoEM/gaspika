from typing import Annotated

from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import APIRouter, Depends, HTTPException, Path, Request
from app.features.notifications.notifications_schemas import BaseNotification, GetNotificationsFilterParams, GetUnreadNotificationsCount, MarkAllAsReadResponse
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
    summary="Obtenir la liste des notifications d'un utilisateur",
    response_model=PagedResponseSchema[BaseNotification],
    responses={200: {"description": "Liste des notifications récupérée avec succés"}},
    status_code=200
)
async def get_notifications(
    request: Request,
    query: GetNotificationsFilterParams = Depends(),
    service: NotificationsService = Depends(get_notifications_service)
):
    return await service.get_all_notifications(request.state.user.id, query)

@notification_router.get(
    "/unread",
    summary="Obtenir le nombre de notifications non lus",
    response_model=GetUnreadNotificationsCount,
    responses={200: {"description": "Nombre de notifications non lus récupéré avec succés"}},
    status_code=200
)
async def get_unread_notifications_count(
    request: Request,
    service: NotificationsService = Depends(get_notifications_service)
):
    count = await service.get_unread_notifications_count(request.state.user.id)
    
    return {
        "message": f"Vous avez {count} notifications",
        "count": count
    }
    
@notification_router.patch(
    "/read-all",
    response_model=MarkAllAsReadResponse,
    summary="Marquer toutes les notifications d'un utilisateur comme lues",
    responses={
        200: {"description": "Toutes les notifications ont été marquées comme lues avec succès"},
    },
    status_code=200
)
async def mark_all_notifications_as_read(
    request: Request,
    service: NotificationsService = Depends(get_notifications_service)
):
    await service.mark_all_as_read(request.state.user.id)
    
    return {"message": "Toutes les notifications ont été marquées comme lues."}

@notification_router.patch(
    "/{notification_id}/read",
    summary="Marquer une notification comme lue",
    responses={
        200: {"description": "Notification marquée comme lue avec succès"},
        404: {"description": "Notification introuvable"}
    },
    status_code=200
)
async def mark_notification_as_read(
    notification_id: Annotated[str, Path(...)],
    service: NotificationsService = Depends(get_notifications_service)
):
    await service.mark_as_read(notification_id)
    
    return {"message": "Notification marquée comme lue."}

@notification_router.delete(
    "/{notification_id}",
    summary="Supprimer une notification",
    status_code=204
)
async def mark_all_notifications_as_read(
    notification_id: Annotated[str, Path(...)],
    service: NotificationsService = Depends(get_notifications_service)
):
    success = await service.delete(notification_id)
    
    if not success:
        raise HTTPException(400, "Impossible de supprimer la notification.")
    
    return None