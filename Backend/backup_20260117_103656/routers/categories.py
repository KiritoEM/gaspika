from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import json
from app.database import get_db
from app.schemas import CategoryOut, CategoryBase
from app.models import FoodCategory
from app.redis_client import redis_client

router = APIRouter(prefix="/categories", tags=["categories"])

@router.get("/", response_model=list[CategoryOut])
async def list_categories(db: AsyncSession = Depends(get_db)):
    cached = redis_client.get("categories:all")
    if cached:
        payloads = json.loads(cached)
        return [CategoryOut.model_validate(p) for p in payloads]
    rows = (await db.execute(select(FoodCategory))).scalars().all()
    data = [CategoryOut.model_validate(r) for r in rows]
    redis_client.setex("categories:all", 300, json.dumps([d.model_dump() for d in data]))
    return data

@router.post("/", response_model=CategoryOut)
async def create_category(payload: CategoryBase, db: AsyncSession = Depends(get_db)):
    c = FoodCategory(**payload.model_dump())
    db.add(c)
    await db.commit()
    await db.refresh(c)
    redis_client.delete("categories:all")
    return  CategoryOut.model_validate(c)