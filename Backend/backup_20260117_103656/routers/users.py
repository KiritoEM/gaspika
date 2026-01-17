from fastapi import APIRouter, Depends, Request
from app.deps import require_user
from app.schemas import UserOut
from app.models import User

router = APIRouter(prefix="/users", tags=["users"],dependencies=[Depends(require_user)])

@router.get("/me", response_model=UserOut)
async def me(request: Request):
    current_user = request.state.user
    return current_user