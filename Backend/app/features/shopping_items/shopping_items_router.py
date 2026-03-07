from typing import Annotated
from fastapi import APIRouter, Depends, Form, HTTPException, Path, Request
from app.features.devices.device_repository import DeviceRepository
from app.core.storages.imgbb import ImgBBProvider
from app.features.images_upload.image_upload_repository import ImageRepository
from app.features.users.user_repository import UserRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.features.shopping_items.shopping_items_repository import ShoppingItemsRepository
from app.core.database import db_session
from app.features.shopping_items.shopping_items_service import ShoppingItemsServices
from app.core.middlewares.auth_middleware import require_user
from app.features.shopping_items.shopping_items_schemas import CreateShoppingItemDTO, CreateShoppingItemOutDTO, FoodSuggestionFilterParams, GetAllShoppingItemsDTO, BaseShoppingListItem, UpdateShoppingItemDTO, GetShoppingItemOutDTO, UpdateShoppingItemOutDTO
from sqlalchemy.ext.asyncio import AsyncSession

shopping_items_router = APIRouter(prefix="/shopping-items", tags=["Shopping Items"], dependencies=[Depends(require_user)])

async def get_shopping_items_services(db: AsyncSession = Depends(db_session)) -> ShoppingItemsServices:
    shopping_list_repo = ShoppingListRepository(db)
    shopping_items_repo = ShoppingItemsRepository(db)
    user_repo = UserRepository(db)
    image_repo = ImageRepository(db)
    device_repo = DeviceRepository(db)
    storage_provider = ImgBBProvider()
    
    return ShoppingItemsServices(
        shopping_list_repo,
        shopping_items_repo,
        image_repo, 
        user_repo,
        storage_provider,
        device_repo
    )

@shopping_items_router.post(
"/{list_id}/add", 
tags=["Shopping Items"],
response_model=CreateShoppingItemOutDTO,
summary="Ajouter un nouvel aliment dans une liste",
responses={
    200: {"description": "Nouvel aliment ajouté succés"},
    404: {"description": "liste introuvable"},
    409: {"description": "L'aliment existe déja dans la liste de la semaine"},
    422: {"description": "Données invalides"},
},  
status_code=201
)
async def add_new_shopping_item(
    request: Request,
    payload: Annotated[CreateShoppingItemDTO, Form(..., media_type="multipart/form-data")],
    list_id: Annotated[int, Path(description="Id de la liste de course")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    await service.add_item_to_list(list_id, request.state.user.id, payload)
    
    return {
        "message": "Aliment  ajouté avec avec succés"
    }

@shopping_items_router.get(
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
    shopping_items =  await service.get_all_items(list_id, request.state.user.id)
    
    return {
        "data": shopping_items    
    }

@shopping_items_router.get(
"/items/{item_id}",
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
    item_id: Annotated[int, Path(description="Id de la l'aliment")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    shopping_item = await service.get_shopping_item_by_id(item_id, request.state.user.id)
    
    if not shopping_item:
            raise HTTPException(status_code=404, detail="Aliment introuvable dans cette liste.")
    
    return {
        "data" : shopping_item
    }
    

@shopping_items_router.get(
"/suggestion",
tags=["Shopping Items"], 
response_model=GetAllShoppingItemsDTO,
summary="Obtenir une suggestion d'aliment si l'utilisateur tape un nom d'aliment",
responses={
    200: {"description": "Suggestions récupérés avec succés"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def get_food_suggestion(
    request: Request,
    query: FoodSuggestionFilterParams = Depends(),
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    shopping_items = await service.search_food_by_name(request.state.user.id, query.food_name)
    
    return {
        "data" : shopping_items
    }

@shopping_items_router.get(
"/{week_number}/available-product",
tags=["Shopping Items"], 
response_model=GetAllShoppingItemsDTO,
summary="Récuperer les aliments disponibles d'une semaine donnée",
responses={
    200: {"description": "Aliments récupérés avec succés"},
    404: {"description": "Liste de courses introuvable"},
    422: {"description": "Données invalides"},
},  
status_code=200
)
async def get_available_shopping_items(
    request: Request,
    week_number: Annotated[int, Path(description="Id de la la liste")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    available_shopping_items = await service.get_available_items(request.state.user.id, week_number)
    
    return {
       "data": available_shopping_items
    }

@shopping_items_router.get(
"/{week_number}/available-product/count", 
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
async def get_available_shopping_items_count(
    request: Request,
    week_number: Annotated[int, Path(description="Id de la la liste")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    items_count = await service.get_available_items_count(request.state.user.id, week_number)
    
    return {
        "count" : items_count
    }

@shopping_items_router.patch(
"/items/{item_id}", 
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
    item_id: Annotated[int, Path(description="Id de la l'aliment")],
    payload: UpdateShoppingItemDTO,
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    await service.update_shopping_item(item_id, request.state.user.id, payload)
    
    return {
        "message" :"Aliment modifié avec succés."
    }


@shopping_items_router.patch(
"/items/{item_id}/complete", 
tags=["Shopping Items"], 
response_model=UpdateShoppingItemOutDTO, 
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
    item_id: Annotated[int, Path(description="Id de la l'aliment")],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    await service.complete_shopping_item(item_id, request.state.user.id)
    
    return {
        "message" :"Aliment marqué comme acheté avec succés"
    }
    
    
@shopping_items_router.delete(
    "/items/{item_id}",
    tags=["Shopping Items"],    
    summary="Supprimer un aliment de la liste",
    status_code=204,
)
async def delete_shopping_lists(
    request: Request,
    item_id: Annotated[int, Path(..., ge=1)],
    service: ShoppingItemsServices = Depends(get_shopping_items_services)
):
    success = await service.delete_shopping_item(item_id, request.state.user.id)
    if not success:
        raise HTTPException(400, "Impossible de supprimer la liste.")
    
    return None