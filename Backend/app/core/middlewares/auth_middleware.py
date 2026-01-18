from fastapi import Depends, HTTPException, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import db_session
from app.core.utils.jwt import decode_JWT
from app.features.users.user_repository import UserRepository
from app.models import User

security = HTTPBearer(auto_error=False)

async def get_user_repository(db: AsyncSession = Depends(db_session)) -> UserRepository:
    """Dependency to get UserRepository instance"""
    return UserRepository(db)

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    userRepo : UserRepository = Depends(get_user_repository)
) -> User | None:
    """Get current user based on token credentials"""
    try:
        print(credentials.credentials)
        payload = decode_JWT(credentials.credentials)
        if not payload or "id" not in payload:
            return None
        
        user_id = payload["id"]
        
        print(user_id)
        
        if not user_id:
            return None
        result = await userRepo.get_user_by_id(user_id)
        return result if result else None
    except JWTError:
        return None

async def require_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(security),  
    userRepo : UserRepository = Depends(get_user_repository)
) -> User:
    user = await get_current_user(credentials, userRepo)
    if not user:
        raise HTTPException(
            status_code=401,
            detail="Token invalide ou expiré",
            headers={"WWW-Authenticate": "Bearer"},
        )
    request.state.user = user
    return user