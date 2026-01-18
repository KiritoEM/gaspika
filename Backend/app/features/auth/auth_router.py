from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import db_session
from app.features.users.user_repository import UserRepository
from app.features.users.user_schemas import UserCreateDTO, UserOut
from app.features.auth.auth_schemas import UserOutDTO
from app.features.users.user_services import UserServices
from app.features.auth.auth_schemas import LoginDTO  
from app.features.auth.auth_services import AuthServices
from app.core.utils.jwt import create_JWT

authRouter = APIRouter(prefix="/auth", tags=["Auth"])

def get_user_services(db: AsyncSession = Depends(db_session)):
    repo = UserRepository(db)
    return UserServices(repo)

def get_auth_services(db: AsyncSession = Depends(db_session)):
    repo = UserRepository(db)
    return AuthServices(repo)

@authRouter.post(
"/register", 
response_model=UserOutDTO,
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
    user_out = UserOut.model_validate(user)
    
    return {
        "data": user_out.model_dump(),
        "access_token": create_JWT({
            "id":str(user.id),
            "email":user.email     
        }),
        "message": "Utilisateur créé avec succès"
    }

@authRouter.post(
"/login",
response_model=UserOutDTO,
summary="Connecter un compte utilisateur",
responses={
    201: {"description": "Utilisateur connecté avec succès"},
    404: {"description": "Adresse email invalide ou inexistante"},
    401: {"description": "mot de passe incorrect"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def register( 
    payload: LoginDTO,
    service: AuthServices = Depends(get_auth_services),
):
    user = await service.login(payload)
    user_out = UserOut.model_validate(user)
    
    return {
        "user": user_out.model_dump(),
         "access_token": create_JWT({
            "id":str(user.id),
            "email":user.email     
        }),
        "message": "Utilisateur connecté avec succès"
    }
