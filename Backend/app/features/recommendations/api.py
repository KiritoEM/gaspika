from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.core.database import get_db
from app.features.recommendations.service import RecommendationService
from app.features.products.schemas import ProductOut
from app.features.shopping_lists.schemas import ShoppingListOut

router = APIRouter(prefix="/recommendations", tags=["recommendations"])

@router.post("/generate-weekly-list/{user_id}", response_model=ShoppingListOut)
async def generate_weekly_list(
    user_id: int,
    week_number: int,
    product_ids: List[int],
    db: AsyncSession = Depends(get_db)
):
    """
    Génère une liste de courses hebdomadaire
    """
    service = RecommendationService(db)
    try:
        shopping_list = await service.generate_weekly_list(user_id, week_number, product_ids)
        return shopping_list
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur: {str(e)}")

@router.get("/for-user/{user_id}", response_model=List[ProductOut])
async def get_user_recommendations(
    user_id: int,
    category_id: int | None = None,
    limit: int = 10,
    db: AsyncSession = Depends(get_db)
):
    """
    Récupère des recommandations personnalisées pour un utilisateur
    """
    service = RecommendationService(db)
    products = await service.get_recommendations(user_id, category_id, limit)
    return products

@router.get("/alternatives/{product_id}", response_model=List[ProductOut])
async def get_alternatives(
    product_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Suggère des alternatives à un produit
    """
    service = RecommendationService(db)
    alternatives = await service.suggest_alternatives(product_id)
    return alternatives

@router.get("/compute-quantity")
async def compute_quantity(
    base_per_person: int,
    household_size: int
):
    """
    Calcule la quantité optimale
    """
    from app.features.recommendations.service import compute_optimal_quantity
    quantity = compute_optimal_quantity(base_per_person, household_size)
    return {
        "base_per_person": base_per_person,
        "household_size": household_size,
        "recommended_quantity": quantity
    }