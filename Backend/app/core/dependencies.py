from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.config import settings

# Import conditionnel pour éviter les erreurs si le repository n'existe pas encore
try:
    from app.features.users.repository import UserRepository
    HAS_USER_REPO = True
except ImportError:
    HAS_USER_REPO = False
    # Créez une classe factice pour éviter les erreurs
    class UserRepository:
        def __init__(self, session):
            self.session = session
        async def get_by_id(self, user_id):
            return None

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
):
    """
    Dépendance pour récupérer l'utilisateur authentifié à partir du token JWT
    """
    token = credentials.credentials
    try:
        # Décoder le token JWT
        payload = jwt.decode(token, settings.app_secret, algorithms=["HS256"])
        user_id = payload.get("userId")
        
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials"
            )
        
        # Récupérer l'utilisateur depuis la base de données
        user_repo = UserRepository(db)
        user = await user_repo.get_by_id(user_id)
        
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        return user
        
    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,  # CORRECTION ICI
            detail=f"Invalid token: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Authentication error: {str(e)}"
        )

async def require_user(request: Request, current_user = Depends(get_current_user)):
    """
    Dépendance qui ajoute l'utilisateur au request.state pour les middlewares
    """
    request.state.user = current_user  # IMPORTANT: pour shopping_items/api.py
    return current_user

# Alias pour compatibilité avec l'ancien code
require_user_dep = require_user

async def get_current_active_user(current_user = Depends(get_current_user)):
    """
    Vérifie que l'utilisateur est actif
    """
    # Exemple: si vous avez un champ is_active dans votre modèle User
    # if not current_user.is_active:
    #     raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

async def get_current_admin_user(current_user = Depends(get_current_user)):
    """
    Vérifie que l'utilisateur est administrateur
    """
    # Exemple: si vous avez un champ is_admin ou role dans votre modèle User
    # if not current_user.is_admin:
    #     raise HTTPException(status_code=403, detail="Not enough permissions")
    return current_user

# Dépendances utilitaires
async def get_optional_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(security, use_cache=False),
    db: AsyncSession = Depends(get_db)
):
    """
    Dépendance qui retourne l'utilisateur s'il est authentifié, sinon None
    """
    try:
        token = credentials.credentials
        payload = jwt.decode(token, settings.app_secret, algorithms=["HS256"])
        user_id = payload.get("userId")
        
        if user_id:
            user_repo = UserRepository(db)
            user = await user_repo.get_by_id(user_id)
            if user:
                request.state.user = user
                return user
    except Exception:
        pass
    
    request.state.user = None
    return None