from fastapi import APIRouter, Depends, Path
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.schemas import PagedResponseSchema
from app.features.users.user_repository import UserRepository
from app.features.shopping_list.shopping_list_schemas import GetAllListsFilterParams, ShoppingListOutDTO
from app.features.shopping_list.shopping_list_services import ShoppingListServices
from app.features.shopping_list.shopping_list_repository import ShoppingListRepository
from app.core.database import db_session
from typing import Annotated

shoppingListRouter = APIRouter(prefix="/shopping-lists", tags=["Shopping Lists"])

def get_shopping_list_services(db: AsyncSession = Depends(db_session)):
    shoppingListRepo = ShoppingListRepository(db)
    userRepo = UserRepository(db)
    
    return ShoppingListServices(shoppingListRepo, userRepo)

@shoppingListRouter.get(
"/{user_id}", 
tags=["Shopping Lists"], 
response_model=PagedResponseSchema[ShoppingListOutDTO],
summary="Obtenir la liste des listes de courses",
responses={
    200: {"description": "Liste des listes de courses"},
    404: {"description": "Utilisateur introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def get_shopping_lists(
    user_id: Annotated[str, Path(title="Id de l'utilisateur")],
    query: GetAllListsFilterParams = Depends(),
    service: ShoppingListServices = Depends(get_shopping_list_services)
):
    return await service.get_all_lists(user_id, query)