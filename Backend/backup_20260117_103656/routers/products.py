from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import json
from app.database import get_db
from app.schemas import ProductOut, ProductBase
from app.models import FoodProduct
from app.redis_client import redis_client

router = APIRouter(prefix="/products", tags=["products"])

@router.get("/", response_model=list[ProductOut])
async def list_products(db: AsyncSession = Depends(get_db)):
    cached = redis_client.get("products:all")
    if cached:
        payloads = json.loads(cached)
        return [ProductOut.model_validate(p) for p in payloads]
    rows = (await db.execute(select(FoodProduct))).scalars().all()
    data = [ProductOut.model_validate(r) for r in rows]
    redis_client.setex("products:all", 300, json.dumps([d.model_dump() for d in data]))
    return data

@router.post("/", response_model=ProductOut)
async def create_product(payload: ProductBase, db: AsyncSession = Depends(get_db)):
    p = FoodProduct(**payload.model_dump())
    db.add(p)
    await db.commit()
    await db.refresh(p)
    redis_client.delete("products:all")
    return p