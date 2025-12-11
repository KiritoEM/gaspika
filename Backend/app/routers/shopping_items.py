from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.deps import require_user
from app.models import ShoppingList, ShoppingListItem, User
from app.schemas import ShoppingListItemOut, ShoppingListItemBase

router = APIRouter(prefix="/shopping-items", tags=["shopping_items"])

@router.get("/{list_id}", response_model=list[ShoppingListItemOut])
async def items_in_list(
    list_id: int,
    category_id: int | None = None,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(require_user)
):
    sl = (await db.execute(
        select(ShoppingList).where(ShoppingList.id == list_id, ShoppingList.user_id == user.id)
    )).scalar_one_or_none()
    if not sl:
        raise HTTPException(status_code=404, detail="List not found")
    q = select(ShoppingListItem).where(ShoppingListItem.shopping_list_id == list_id)
    if category_id:
        q = q.where(ShoppingListItem.category_id == category_id)
    rows = (await db.execute(q)).scalars().all()
    return rows

@router.post("/{list_id}/add", response_model=ShoppingListItemOut)
async def add_item(
    list_id: int,
    payload: ShoppingListItemBase,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(require_user)
):
    sl = (await db.execute(
        select(ShoppingList).where(ShoppingList.id == list_id, ShoppingList.user_id == user.id)
    )).scalar_one_or_none()
    if not sl:
        raise HTTPException(status_code=404, detail="List not found")
    item = ShoppingListItem(shopping_list_id=list_id, **payload.model_dump())
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item