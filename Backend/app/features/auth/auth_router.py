from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.features.devices.device_repository import DeviceRepository
from app.core.database import db_session
from app.features.users.user_repository import UserRepository
from app.features.users.user_schemas import UserCreateDTO, BaseUser
from app.features.auth.auth_schemas import BaseUserDTO
from app.features.users.user_service import UserServices
from app.features.auth.auth_schemas import LoginDTO  
from app.features.auth.auth_service import AuthServices
from app.core.utils.jwt import create_JWT

auth_router = APIRouter(prefix="/auth", tags=["Auth"])

def get_user_services(db: AsyncSession = Depends(db_session)):
    repo = UserRepository(db)
    return UserServices(repo)

def get_auth_services(db: AsyncSession = Depends(db_session)):
    user_repo = UserRepository(db)
    device_repo = DeviceRepository(db)
    
    return AuthServices(user_repo, device_repo)

@auth_router.post(
"/register", 
response_model=BaseUserDTO,
summary="Créer un compte utilisateur",
responses={
    201: {"description": "Utilisateur créé avec succès"},
    409: {"description": "Email déjà utilisé"},
    422: {"description": "Données invalides"},
},  
status_code=201
)
async def register(
    payload: UserCreateDTO,
    service: UserServices = Depends(get_user_services),
):
    user =  await service.create_user(payload)
    user_out = BaseUser.model_validate(user)
    
    return {
        "user": user_out.model_dump(),
        "access_token": create_JWT({
            "id":str(user.id),
            "email":user.email     
        }),
        "message": "Utilisateur créé avec succès"
    }

@auth_router.post(
"/login",
response_model=BaseUserDTO,
summary="Connecter un compte utilisateur",
responses={
    201: {"description": "Utilisateur connecté avec succès"},
    404: {"description": "Adresse email invalide ou inexistante"},
    401: {"description": "mot de passe incorrect"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def login( 
    payload: LoginDTO,
    service: AuthServices = Depends(get_auth_services),
):
    user = await service.login(payload)
    user_out = BaseUser.model_validate(user)
    
    return {
        "user": user_out.model_dump(),
         "access_token": create_JWT({
            "id":str(user.id),
            "email":user.email     
        }),
        "message": "Utilisateur connecté avec succès"
    }
