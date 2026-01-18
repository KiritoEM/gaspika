from typing import Annotated
from fastapi import APIRouter, Depends, Path, Request
from app.features.users.user_repository import UserRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.features.shopping_items.shopping_items_repository import ShoppingItemsRepository
from app.features.foods.food_repository import FoodRepository
from app.core.database import db_session
from app.features.shopping_lists.shopping_list_services import ShoppingListServices
from app.features.shopping_items.shopping_items_services import ShoppingItemsServices
from app.core.middlewares.auth_middleware import require_user
from app.features.shopping_items.shopping_items_schemas import CreateShoppingItemDTO, CreateShoppingItemOutDTO, GetAllShoppingItemsDTO
from sqlalchemy.ext.asyncio import AsyncSession

shoppingItemsRouter = APIRouter(prefix="/shopping-items", tags=["Shopping Items"], dependencies=[Depends(require_user)])

async def get_shopping_items_services(db: AsyncSession = Depends(db_session)) -> ShoppingItemsServices:
    shoppingListRepo = ShoppingListRepository(db)  
    foodRep = FoodRepository(db)
    shoppingItemsRepo = ShoppingItemsRepository(db)
    userRepo = UserRepository(db)  
    return ShoppingItemsServices(shoppingListRepo, foodRep, shoppingItemsRepo, userRepo)

@shoppingItemsRouter.post(
"/{list_id}/add", 
tags=["Shopping Items"], 
response_model=CreateShoppingItemOutDTO,
summary="Ajouter un nouvel aliment dans une liste",
responses={
    200: {"description": "Liste de courses générée avec succés"},
    404: {"description": "Utilisateur ou liste introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=201
)
async def create_shopping_lists(
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
"/{list_id}", 
tags=["Shopping Items"], 
response_model=GetAllShoppingItemsDTO,
summary="Obtenir la liste des aliments dans une liste",
responses={
    200: {"description": "Liste de courses récupérée avec succés"},
    404: {"description": "Aliment ou liste introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def get_shopping__list_items(
    request: Request,
    list_id: Annotated[int, Path(description="Id de la liste de course")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    created_list =  await service.get_all_items(list_id, request.state.user.id)
    
    return {
        "results": created_list    
    }
