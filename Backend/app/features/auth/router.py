from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import db_session
from app.features.users.repository import UserRepository
from app.features.users.schemas import UserCreate, UserOut
from app.features.users.services import UserServices

authRouter = APIRouter(prefix="/auth", tags=["auth"])

def get_user_services(db: AsyncSession = Depends(db_session)):
    repo = UserRepository(db)
    return UserServices(repo)

@authRouter.post(
"/register", 
response_model=UserOut,
summary="Créer un compte utilisateur",
responses={
    201: {"description": "Utilisateur créé avec succès"},
    409: {"description": "Email déjà utilisé"},
    422: {"description": "Données invalides"},
},  
status_code=201
)
async def register(
    payload: UserCreate,
    service: UserServices = Depends(get_user_services),
):
    return await service.create_user(payload)
