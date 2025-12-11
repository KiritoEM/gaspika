from fastapi import APIRouter, Depends
from app.deps import require_user
from app.schemas import UserOut
from app.models import User

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/me", response_model=UserOut)
async def me(current_user: User = Depends(require_user)):
    return current_user