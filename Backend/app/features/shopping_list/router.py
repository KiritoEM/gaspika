from fastapi import APIRouter

shoppingRouter = APIRouter(prefix="/shopping-lists", tags=["Shopping Lists"])

# @shoppingRouter.get("/", tags=["Shopping Lists"])