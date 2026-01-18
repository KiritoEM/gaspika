from fastapi import FastAPI, APIRouter
from app.database import Base, engine
from app.routers import auth, users, categories, products, shopping_listss, shopping_items, predictions

app = FastAPI(
    title="Grocery Planner API",
    description="API pour gérer les courses : utilisateurs, catégories, produits, listes et items."
)

# Création des tables au démarrage
@app.on_event("startup")
async def startup_event():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

api_router = APIRouter(prefix="/api")
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(categories.router)
api_router.include_router(products.router)
api_router.include_router(shopping_listss.router)
api_router.include_router(shopping_items.router)
api_router.include_router(predictions.router)

app.include_router(api_router)

@app.get("/", tags=["Root"])
async def root():
    return {"message": "Bienvenue sur ton API de gestion des courses 🚀"}