from datetime import datetime
import random
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, extract
from app.core.database import get_db  # CORRIGÉ
from app.core.dependencies import require_user  # CORRIGÉ
from app.features.shopping_lists.models import ShoppingList  # CORRIGÉ
from app.features.shopping_items.models import ShoppingListItem  # CORRIGÉ
from app.features.shopping_items.schemas import ShoppingListItemOut, ShoppingListItemBase  # CORRIGÉ

router = APIRouter(prefix="/shopping-items", tags=["shopping_items"], dependencies=[Depends(require_user)])

@router.get(
    "/{list_id}", 
    response_model=list[ShoppingListItemOut],
    summary="Obtenir les items d'une liste",
    description="Récupère tous les items d'une liste de courses avec possibilité de filtrer par catégorie"
)
async def items_in_list(
    request: Request,
    list_id: int,
    category_id: int | None = None,
    db: AsyncSession = Depends(get_db),
):
    sl = (await db.execute(
        select(ShoppingList).where(ShoppingList.id == list_id, ShoppingList.user_id == request.state.user.id)
    )).scalar_one_or_none()
    if not sl:
        raise HTTPException(status_code=404, detail="List not found")
    q = select(ShoppingListItem).where(ShoppingListItem.shopping_list_id == list_id)
    if category_id:
        q = q.where(ShoppingListItem.category_id == category_id)
    rows = (await db.execute(q)).scalars().all()
    return rows


@router.get(
    "/{week_number}/available-products-count", 
    response_model=dict,
    summary="Nombre de produits disponibles",
    description="Retourne le nombre total de produits dans la liste de courses d'une semaine donnée"
)
async def available_products_count(
    request: Request,
    week_number: int,
    category_id: int | None = None,
    db: AsyncSession = Depends(get_db),
):
    # Verify shopping list ownership
    sl = (await db.execute(
        select(ShoppingList).where(
            ShoppingList.week_number == week_number,
            ShoppingList.user_id == request.state.user.id,
            extract('year', ShoppingList.created_at) == datetime.now().year,
        )
    )).scalar_one_or_none()
    if not sl:
        return {"count": 0}
    
    # Count available products
    q = select(ShoppingListItem).where(
        ShoppingListItem.shopping_list_id == sl.id, 
        ShoppingListItem.is_purchased == False
    )

    # Filter by category
    if category_id:
        q = q.where(ShoppingListItem.category_id == category_id)

    rows = (await db.execute(q)).scalars().all()
    return {
        "count": len(rows)
    }

@router.get(
    "/{week_number}/shopping-week", 
    response_model=list[ShoppingListItemOut],
    summary="Recuperer les produits de la semaine",
    description="Retourne des produits de la liste de courses de la semaine"
)
async def shopping_week_items(
    request: Request,
    week_number: int,
    db: AsyncSession = Depends(get_db),
):
    if week_number < 1 or week_number > 53:
        raise HTTPException(status_code=400, detail="Week number must be between 1 and 53")

    # Verify shopping list ownership
    sl = (await db.execute(
        select(ShoppingList).where(
            ShoppingList.week_number == week_number,
            ShoppingList.user_id == request.state.user.id,
            extract('year', ShoppingList.created_at) == datetime.now().year
        )
    )).scalar_one_or_none()
    if not sl:
        return []
    
    # Get all items
    q = select(ShoppingListItem).where(
        ShoppingListItem.shopping_list_id == sl.id, 
        ShoppingListItem.is_purchased == False
    )
    rows = (await db.execute(q)).scalars().all()

    if len(rows) <= 5:
        return rows

    # Select 5 items randomly
    return random.sample(rows, 5)

@router.post(
    "/{list_id}/add", 
    response_model=ShoppingListItemOut,
    summary="Ajouter un item à la liste",
    description="Ajoute un nouveau produit à une liste de courses existante",
    status_code=201
)
async def add_item(
    request: Request,
    list_id: int,
    payload: ShoppingListItemBase,
    db: AsyncSession = Depends(get_db),
):
    sl = (await db.execute(
        select(ShoppingList).where(ShoppingList.id == list_id, ShoppingList.user_id == request.state.user.id)
    )).scalar_one_or_none()
    if not sl:
        raise HTTPException(status_code=404, detail="List not found")
    
    # Add item
    item = ShoppingListItem(shopping_list_id=list_id, **payload.model_dump())
    db.add(item)
    
    await db.commit()
    await db.refresh(item)

    return item