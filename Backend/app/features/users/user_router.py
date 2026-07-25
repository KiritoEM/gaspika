from fastapi import APIRouter, Depends, HTTPException, Request
from app.core.redis_client import get_redis_client
from app.core.storages.imgbb import ImgBBProvider
from app.features.devices.device_repository import DeviceRepository
from app.features.users.user_preference_repository import UserPreferenceRepository
from app.features.users.user_schemas import ChangePasswordDTO, DeleteAccountDTO, GetNotificationPreferenceDTO, GetUserDTO, LogoutDTO, MessageResponse, UpdateNotificationPreferenceDTO, UpdateUserDTO, UpdateUserOutDTO
from app.features.users.user_repository import UserRepository
from app.features.users.user_service import UserServices
from app.core.database import db_session
from app.core.middlewares.auth_middleware import require_user
from sqlalchemy.ext.asyncio import AsyncSession

user_router = APIRouter(prefix="/user", tags=["User"], dependencies=[Depends(require_user)])

async def get_users_service(db: AsyncSession = Depends(db_session)) -> UserServices:
    user_repo = UserRepository(db)
    device_repo = DeviceRepository(db)
    preference_repo = UserPreferenceRepository(db)
    storage_provider = ImgBBProvider()
    redis_client = get_redis_client()

    return UserServices(user_repo, device_repo, preference_repo, storage_provider, redis_client)

@user_router.get(
"/me",
response_model=GetUserDTO,
summary="Obtenir les informations d'un utilisateur",
responses={
    200: {"description": "Informations sur l'uitli"},
    404: {"description": "Utilisateur introuvable"}
},
status_code=200
)
async def get_user(request: Request, service: UserServices = Depends(get_users_service)):
    user =  await service.get_user_by_id(request.state.user.id)

    if not user:
        raise HTTPException(status_code=404)

    return {
        "data" : user
    }

@user_router.patch(
"/me",
response_model=UpdateUserOutDTO,
summary="Modifier les informations d'un utilisateur",
responses={
    200: {"description": "Informations modifiées avec succés"},
    404: {"description": "Utilisateur introuvable"},
    409: {"description": "Email déjà utilisé"},
    422: {"description": "Données invalides"},
},
status_code=200
)
async def update_user(
    request: Request,
    payload: UpdateUserDTO,
    service: UserServices = Depends(get_users_service),
):
    updated_user = await service.update_user(request.state.user.id, payload)

    return {
        "data": updated_user,
        "message": "Informations modifiées avec succés"
    }

@user_router.patch(
"/me/password",
response_model=MessageResponse,
summary="Changer le mot de passe d'un utilisateur",
responses={
    200: {"description": "Mot de passe modifié avec succés"},
    400: {"description": "Le nouveau mot de passe est identique à l'ancien"},
    401: {"description": "Mot de passe incorrect"},
    404: {"description": "Utilisateur introuvable"},
    422: {"description": "Données invalides"},
},
status_code=200
)
async def change_password(
    request: Request,
    payload: ChangePasswordDTO,
    service: UserServices = Depends(get_users_service),
):
    await service.change_password(request.state.user.id, payload)

    return {"message": "Mot de passe modifié avec succés"}

@user_router.get(
"/me/notification-preferences",
response_model=GetNotificationPreferenceDTO,
summary="Obtenir les préférences de notification d'un utilisateur",
responses={
    200: {"description": "Préférences de notification récupérées avec succés"},
},
status_code=200
)
async def get_notification_preferences(
    request: Request,
    service: UserServices = Depends(get_users_service),
):
    preferences = await service.get_notification_preferences(request.state.user.id)

    return {
        "data": preferences
    }

@user_router.patch(
"/me/notification-preferences",
response_model=GetNotificationPreferenceDTO,
summary="Modifier les préférences de notification d'un utilisateur",
responses={
    200: {"description": "Préférences de notification modifiées avec succés"},
    404: {"description": "Préférences de notification introuvables"},
    422: {"description": "Données invalides"},
},
status_code=200
)
async def update_notification_preferences(
    request: Request,
    payload: UpdateNotificationPreferenceDTO,
    service: UserServices = Depends(get_users_service),
):
    preferences = await service.update_notification_preferences(request.state.user.id, payload)

    return {
        "data": preferences
    }

@user_router.delete(
"/me",
response_model=MessageResponse,
summary="Supprimer le compte d'un utilisateur",
responses={
    200: {"description": "Compte supprimé avec succés"},
    401: {"description": "Mot de passe incorrect"},
    404: {"description": "Utilisateur introuvable"},
    422: {"description": "Données invalides"},
},
status_code=200
)
async def delete_account(
    request: Request,
    payload: DeleteAccountDTO,
    service: UserServices = Depends(get_users_service),
):
    await service.delete_account(request.state.user.id, payload)

    return {"message": "Compte supprimé avec succés"}

@user_router.delete(
    "/logout",
    summary="Déconnexion de l'utilisateur",
    responses={
        200: {"description": "Déconnexion réussie"},
        404: {"description": "Device introuvable"},
    },
    status_code=200,
)
async def logout(
    body: LogoutDTO,
    service: UserServices = Depends(get_users_service),
):
    await service.logout(body.fcm_token)

    return {"message": "Déconnexion réussie."}
