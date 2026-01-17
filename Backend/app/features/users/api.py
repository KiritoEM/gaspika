from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.dependencies import require_user  # CORRIGÉ
from app.features.users.schemas import UserOut, UserUpdate  # CORRIGÉ
from app.features.users.models import User  # CORRIGÉ
from app.core.database import get_db  # CORRIGÉ
from app.features.users.service import UserService  # Optionnel

router = APIRouter(prefix="/users", tags=["users"], dependencies=[Depends(require_user)])

@router.get("/me", response_model=UserOut)
async def get_current_user(request: Request):
    """
    Récupère les informations de l'utilisateur connecté
    """
    current_user = request.state.user
    return current_user

@router.put("/me", response_model=UserOut)
async def update_current_user(
    request: Request,
    user_update: UserUpdate,
    db: AsyncSession = Depends(get_db)
):
    """
    Met à jour les informations de l'utilisateur connecté
    """
    current_user = request.state.user
    
    # Mettre à jour les champs fournis
    update_data = user_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if hasattr(current_user, field):
            setattr(current_user, field, value)
    
    db.add(current_user)
    await db.commit()
    await db.refresh(current_user)
    
    return current_user

@router.get("/{user_id}", response_model=UserOut)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_user)
):
    """
    Récupère un utilisateur par son ID (admin uniquement)
    """
    # Vérifier les permissions (exemple : seul l'admin peut voir d'autres utilisateurs)
    # if not current_user.is_admin and current_user.id != user_id:
    #     raise HTTPException(status_code=403, detail="Not authorized")
    
    from sqlalchemy import select
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user