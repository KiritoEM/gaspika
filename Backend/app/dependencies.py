from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.core.config import settings
from app.features.users.models import User

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
):
    """
    Récupère l'utilisateur authentifié à partir du token JWT
    """
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.app_secret, algorithms=["HS256"])
        user_id = payload.get("userId")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials"
            )
        
        # Récupérer l'utilisateur directement sans repository
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        return user
        
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

async def require_user(request: Request, current_user = Depends(get_current_user)):
    """
    Dépendance qui ajoute l'utilisateur au request.state
    IMPORTANT pour shopping_items/api.py et autres
    """
    request.state.user = current_user
    return current_user

# Alias pour compatibilité avec l'ancien code
require_user_dep = require_user

async def get_optional_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(security, use_cache=False),
    db: AsyncSession = Depends(get_db)
):
    """
    Récupère l'utilisateur s'il est authentifié, sinon None
    """
    try:
        token = credentials.credentials
        payload = jwt.decode(token, settings.app_secret, algorithms=["HS256"])
        user_id = payload.get("userId")
        
        if user_id:
            result = await db.execute(select(User).where(User.id == user_id))
            user = result.scalar_one_or_none()
            if user:
                request.state.user = user
                return user
    except Exception:
        pass
    
    request.state.user = None
    return None