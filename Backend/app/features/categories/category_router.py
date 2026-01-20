from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import db_session
from app.features.categories.category_schemas import CategoryOutDTO, CreateCategoryDTO
from app.features.categories.category_services import CategoryServices
from app.features.categories.category_repository import CategoryRepository

categoryRouter = APIRouter(prefix="/categories", tags=["Categories"])

async def get_category_services(db: AsyncSession = Depends(db_session)) -> CategoryServices:
    repo = CategoryRepository(db)
    return CategoryServices(repo)

@categoryRouter.get(
    "/",
    response_model=list[CategoryOutDTO],
    summary="Obtenir toutes les catégories",
    status_code=200
)
async def list_categories(
    service: CategoryServices = Depends(get_category_services)
):
    return await service.get_all_categories()

@categoryRouter.post(
    "/",
    response_model=CategoryOutDTO,
    summary="Créer une catégorie",
    status_code=201
)
async def create_category(
    payload: CreateCategoryDTO,
    service: CategoryServices = Depends(get_category_services)
):
    return await service.create_category(payload)