from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, Path, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.middlewares.auth_middleware import require_user
from app.core.schemas import PagedResponseSchema
from app.features.users.user_repository import UserRepository
from app.features.shopping_lists.shopping_list_schemas import CreateShoppingListDTO, CreateShoppingListOutDTO, GetAllListsFilterParams, BaseShoppingList, UpdateShoppingListDTO
from app.features.shopping_lists.shopping_list_service import ShoppingListServices
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.core.database import db_session

shopping_list_router = APIRouter(prefix="/shopping-lists", tags=["Shopping Lists"], dependencies=[Depends(require_user)])

async def get_shopping_lists_service(db: AsyncSession = Depends(db_session)) -> ShoppingListServices:
    shoppingListRepo = ShoppingListRepository(db)
    userRepo = UserRepository(db)
    return ShoppingListServices(shoppingListRepo, userRepo)

@shopping_list_router.get(
"/",
response_model=PagedResponseSchema[BaseShoppingList],
summary="Obtenir la liste des listes de courses",
responses={
    200: {"description": "Liste des listes de courses"},
    },  
status_code=200
)
async def get_shopping_lists(
    request: Request, 
    query: GetAllListsFilterParams = Depends(),
    service: ShoppingListServices = Depends(get_shopping_lists_service)
):
    return await service.get_all_lists(request.state.user.id, query)

@shopping_list_router.post(
"/generate", 
response_model=CreateShoppingListOutDTO,
summary="Générer une liste de courses",
responses={
    200: {"description": "Liste de courses générée avec succés"},
    409: {"description": "Une liste existe déja pour cette semaine"},
    422: {"description": "Données invalides"},
},  
status_code=201
)
async def create_shopping_list(
    request: Request,
    payload: CreateShoppingListDTO,
    service: ShoppingListServices = Depends(get_shopping_lists_service)
):
    created_list =  await service.generate_list(payload.week_number, request.state.user.id, payload.name)
    
    return {
        "data": created_list,
        "message": "Liste créée avec succés"
    }
    

@shopping_list_router.patch(
"/{list_id}", 
response_model=CreateShoppingListOutDTO,
summary="Modifier une liste de courses",
responses={
    200: {"description": "Liste de courses modifiée avec succés"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def update_shopping_list(
    request: Request,
    payload: UpdateShoppingListDTO,
    list_id: Annotated[int, Path(..., ge=1)],
    service: ShoppingListServices = Depends(get_shopping_lists_service)
):
    updated_list =  await service.update_list(request.state.user.id, list_id, payload)
    
    return {
        "data": updated_list,
        "message": "Liste créée avec succés"
    }

@shopping_list_router.delete(
    "/{list_id}",
    summary="Supprimer une liste",
    status_code=204,
)
async def delete_shopping_lists(
    request: Request,
    list_id: Annotated[int, Path(..., ge=1)],
    service: ShoppingListServices = Depends(get_shopping_lists_service)
):
    success = await service.delete_list(request.state.user.id, list_id)
    if not success:
        raise HTTPException(400, "Impossible de supprimer la liste.")
    
    return None