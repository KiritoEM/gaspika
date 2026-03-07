from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import db_session
from app.features.categories.category_schemas import CategoryOutDTO, CreateCategoryDTO, CreateCategoryOutDTO
from app.features.categories.category_service import CategoryServices
from app.features.categories.category_repository import CategoryRepository

category_router = APIRouter(prefix="/categories", tags=["Categories"])

async def get_category_services(db: AsyncSession = Depends(db_session)) -> CategoryServices:
    repo = CategoryRepository(db)
    return CategoryServices(repo)

@category_router.get(
    "/",
    response_model=CategoryOutDTO,
    summary="Obtenir toutes les catégories",
    status_code=200,
    responses= {
        200: {"description": "Toutes les catégories récupérées avec succés"},
    }
)
async def list_categories(
    service: CategoryServices = Depends(get_category_services)
):
    categories = await service.get_all_categories()
    
    return {
        "data": categories
    }

@category_router.post(
    "/",
    summary="Créer une ou plusieurs catégorie(s)",
    status_code=201,
    response_model=CreateCategoryOutDTO,
    responses= {
        200: {"description": "Catégorie(s) créée(s) avec succés"},
    }
)
async def create_category(
    payload: list[CreateCategoryDTO],
    service: CategoryServices = Depends(get_category_services)
):
    await service.create_category(payload)
    
    return {
        "message": "Catégorie(s) créée(s) avec succés"
    }