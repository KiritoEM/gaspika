from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from app.features.auth.auth_router import authRouter
from app.features.shopping_lists.shopping_list_router import shoppingListRouter
from app.features.categories.category_router import categoryRouter
from app.features.shopping_items.shopping_items_router import shoppingItemsRouter

app = FastAPI(
    title="Gaspika API",
    description="API pour l'application Gaspika",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
)

api_router = APIRouter(prefix="/api")
api_router.include_router(authRouter)
api_router.include_router(shoppingListRouter)
api_router.include_router(categoryRouter)
api_router.include_router(shoppingItemsRouter)

app.include_router(api_router)

@app.get("/")
async def root():
    return {"message": "Server is running !!!"}

@app.get("/health")
async def root():
  return {"status": "healthy"}
