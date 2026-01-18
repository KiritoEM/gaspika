from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.database import get_db
from app.deps import require_user
from app.schemas import ShoppingListOut
from app.models import ShoppingList, User
from app.services.list_generator import generate_weekly_list

router = APIRouter(prefix="/shopping-lists", tags=["shopping_listss"], dependencies=[Depends(require_user)])

@router.get("/", response_model=list[ShoppingListOut])
async def my_lists(request: Request, db: AsyncSession = Depends(get_db)):
    rows = (await db.execute(select(ShoppingList)
        .options(selectinload(ShoppingList.items)) 
        .where(ShoppingList.user_id == request.state.user.id))).scalars().all()
    return rows

@router.post("/generate", response_model=ShoppingListOut)
async def generate(
    request: Request,
    week_number: int = 1,
    product_ids: list[int] = [],
    db: AsyncSession = Depends(get_db),
):
     #Check if list already exists with week number
    result = await db.execute(select(ShoppingList).where(ShoppingList.week_number == week_number, ShoppingList.user_id == request.state.user.id))
    existing_list = result.scalar_one_or_none()
    if existing_list:
        return HTTPException(status_code=400, detail="List already exists for this week")
    
    sl = await generate_weekly_list(db, request.state.user.id, week_number, product_ids)
    await db.commit()
    await db.refresh(sl)
    await db.refresh(sl, attribute_names=["items"])
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