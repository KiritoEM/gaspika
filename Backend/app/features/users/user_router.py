from fastapi import APIRouter, Depends, HTTPException, Request
from app.features.users.user_schemas import GetUserDTO
from app.features.users.user_repository import UserRepository
from app.features.users.user_service import UserServices
from app.core.database import db_session
from app.core.middlewares.auth_middleware import require_user
from sqlalchemy.ext.asyncio import AsyncSession

user_router = APIRouter(prefix="/user", tags=["Users"], dependencies=[Depends(require_user)])

async def get_users_services(db: AsyncSession = Depends(db_session)) -> UserServices:
    user_repo = UserRepository(db)
    
    return UserServices(user_repo)

@user_router.get(
"/me",
tags= ["Users"],
response_model=GetUserDTO,
summary="Obtenir les informations d'un utilisateur",
responses={
    200: {"description": "Informations sur l'uitli"},
    404: {"description": "Utilisateur introuvable"}
},  
status_code=200
)
async def get_user(request: Request, service: UserServices = Depends(get_users_services)):
    user =  await service.get_user_by_id(request.state.user.id)
    
    if not user:
        raise HTTPException(status_code=404)
    
    return {
        "data" : user
    }