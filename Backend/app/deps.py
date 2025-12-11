from fastapi import Depends, HTTPException, status
from jose import jwt, JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.config import settings
from app.models import User

async def get_current_user(token: str, db: AsyncSession) -> User | None:
    try:
        payload = jwt.decode(token, settings.app_secret, algorithms=["HS256"])
        email = payload.get("sub")
        if not email:
            return None
        result = await db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()
    except JWTError:
        return None

async def require_user(token: str, db: AsyncSession = Depends(get_db)) -> User:
    user = await get_current_user(token, db)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    return user