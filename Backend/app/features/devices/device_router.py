from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.features.devices.device_schemas import UpdateDeviceDTO, UpdateDeviceOutDTO
from app.features.devices.device_service import DeviceServices
from app.core.database import db_session
from app.features.devices.device_repository import DeviceRepository
from app.core.middlewares.auth_middleware import require_user 

device_router = APIRouter(
    prefix="/devices",
    tags=["Devices"],
    dependencies=[Depends(require_user)]
)

async def get_device_service(db: AsyncSession = Depends(db_session)):
    device_repo = DeviceRepository(db)
    return DeviceServices(device_repo)


@device_router.patch(
    "/",
    response_model=UpdateDeviceOutDTO,
    summary="Mettre à jour le FCM token du device utilisateur",
    description="Met à jour le **FCM Token** associé au device de l'utilisateur authentifié.",  # ← virgule ici
    responses={
        200: {"description": "Device mis à jour avec succès"},
        422: {"description": "Données invalides"},
    },
    status_code=200
)
async def update_device(
    request: Request,
    payload: UpdateDeviceDTO,
    service: DeviceServices = Depends(get_device_service)
):
    await service.update_device(request.state.user.id, payload)

    return {
        "message": "Device mis à jour avec succès."
    }
