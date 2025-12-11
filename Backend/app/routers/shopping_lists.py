from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.deps import require_user
from app.schemas import ShoppingListOut
from app.models import ShoppingList, User
from app.services.list_generator import generate_weekly_list

router = APIRouter(prefix="/shopping-lists", tags=["shopping_lists"])

@router.get("/", response_model=list[ShoppingListOut])
async def my_lists(db: AsyncSession = Depends(get_db), user: User = Depends(require_user)):
    rows = (await db.execute(select(ShoppingList).where(ShoppingList.user_id == user.id))).scalars().all()
    return rows

@router.post("/generate", response_model=ShoppingListOut)
async def generate(
    week_number: int = 1,
    product_ids: list[int] = [],
    db: AsyncSession = Depends(get_db),
    user: User = Depends(require_user)
):
    sl = await generate_weekly_list(db, user.id, week_number, product_ids)
    await db.commit()
    await db.refresh(sl)
    return sl

@router.post("/{list_id}/complete", response_model=ShoppingListOut)
async def complete_list(list_id: int, db: AsyncSession = Depends(get_db), user: User = Depends(require_user)):
    sl = (await db.execute(
        select(ShoppingList).where(ShoppingList.id == list_id, ShoppingList.user_id == user.id)
    )).scalar_one_or_none()
    if not sl:
        raise HTTPException(status_code=404, detail="List not found")
    sl.is_completed = True
    await db.commit()
    await db.refresh(sl)
    return sl