from typing import Annotated
from fastapi import APIRouter, Depends, Path, Request
from app.features.users.user_repository import UserRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.features.shopping_items.shopping_items_repository import ShoppingItemsRepository
from app.core.database import db_session
from app.features.shopping_items.shopping_items_services import ShoppingItemsServices
from app.core.middlewares.auth_middleware import require_user
from app.features.shopping_items.shopping_items_schemas import CreateShoppingItemDTO, CreateShoppingItemOutDTO, GetAllShoppingItemsDTO, ShoppingListItemOut, UpdateShoppingItemDTO, GetShoppingItemOutDTO, UpdateShoppingItemOutDTO
from sqlalchemy.ext.asyncio import AsyncSession

shoppingItemsRouter = APIRouter(prefix="/shopping-items", tags=["Shopping Items"], dependencies=[Depends(require_user)])

async def get_shopping_items_services(db: AsyncSession = Depends(db_session)) -> ShoppingItemsServices:
    shoppingListRepo = ShoppingListRepository(db)  
    shoppingItemsRepo = ShoppingItemsRepository(db)
    userRepo = UserRepository(db)  
    return ShoppingItemsServices(shoppingListRepo, shoppingItemsRepo, userRepo)

@shoppingItemsRouter.post(
"/{list_id}/add", 
tags=["Shopping Items"], 
response_model=CreateShoppingItemOutDTO,
summary="Ajouter un nouvel aliment dans une liste",
responses={
    200: {"description": "Nouvel aliment ajouté succés"},
    404: {"description": "Utilisateur ou liste introuvable"},
    409: {"description": "L'aliment existe déja dans la liste de la semaine"},
    422: {"description": "Données invalides"},
},  
status_code=201
)
async def add_new_shopping_item(
    request: Request,
    payload: CreateShoppingItemDTO,
    list_id: Annotated[int, Path(description="Id de la liste de course")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    created_list =  await service.add_item_to_list(list_id, request.state.user.id, payload)
    
    return {
        "item": created_list,
        "message": "Aliment  ajouté avec avec succés"
    }

@shoppingItemsRouter.get(
"/{list_id}/items", 
tags=["Shopping Items"], 
response_model=GetAllShoppingItemsDTO,
summary="Obtenir la liste des aliments dans une liste specifique",
responses={
    200: {"description": "Liste des aliments dans une course récupérée avec succés"},
    404: {"description": "Aliment ou liste introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def get_shopping_list_items(
    request: Request,
    list_id: Annotated[int, Path(description="Id de la liste de course")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    created_list =  await service.get_all_items(list_id, request.state.user.id)
    
    return {
        "results": created_list    
    }

@shoppingItemsRouter.get(
"/{list_id}/items/{item_id}", 
tags=["Shopping Items"], 
response_model=GetShoppingItemOutDTO,
summary="Obtenir un aliment specifique dans une liste de courses",
responses={
    200: {"description": "Aliment récupéré avec succés"},
    404: {"description": "Aliment ou liste de courses introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def get_shopping_item(
    request: Request,
    list_id: Annotated[int, Path(description="Id de la la liste")],
    item_id: Annotated[int, Path(description="Id de la l'aliment")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    shopping_item = await service.get_shopping_item_by_id(item_id, list_id, request.state.user.id)
    
    return {
        "item" : shopping_item
    }


@shoppingItemsRouter.get(
"/{week_number}/available-product", 
tags=["Shopping Items"], 
response_model=dict,
summary="Récuperer le nombre total d'aliments disponibles d'une semaine donnée",
responses={
    200: {"description": "Nombre d'aliments récupéré avec succés"},
    404: {"description": "Liste de courses introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def get_shopping_item(
    request: Request,
    week_number: Annotated[int, Path(description="Id de la la liste")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    items_count = await service.get_available_items_count(request.state.user.id, week_number)
    
    return {
        "count" : items_count
    }

@shoppingItemsRouter.patch(
"/{list_id}/items/{item_id}", 
tags=["Shopping Items"],
response_model=UpdateShoppingItemOutDTO,
summary="Mettre a jour certaines informations d'un element dans une liste",
responses={
    200: {"description": "Aliment mis a jour avec succés"},
    404: {"description": "Aliment ou liste de courses introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def update_shopping_item(
    request: Request,
    list_id: Annotated[int, Path(description="Id de la la liste")],
    item_id: Annotated[int, Path(description="Id de la l'aliment")],
    payload: UpdateShoppingItemDTO,
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    updated_shopping_item = await service.update_shopping_item(item_id, list_id, request.state.user.id, payload)
    
    return {
        "item" : updated_shopping_item
    }


@shoppingItemsRouter.patch(
"/{list_id}/items/{item_id}/complete", 
tags=["Shopping Items"], 
response_model=ShoppingListItemOut,
summary="Marquer un aliment comme acheté",
responses={
    200: {"description": "Aliment marqué comme acheté"},
    404: {"description": "Aliment ou liste de courses introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def mark_item_as_complete(
    request: Request,
    list_id: Annotated[int, Path(description="Id de la la liste")],
    item_id: Annotated[int, Path(description="Id de la l'aliment")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    return await service.complete_shopping_item(item_id, list_id, request.state.user.id)

