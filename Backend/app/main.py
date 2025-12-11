from fastapi import FastAPI
from app.database import Base, engine
from app.routers import auth, users, categories, products, shopping_lists, shopping_items

app = FastAPI(
    title="Grocery Planner API",
    description="API pour gérer les courses : utilisateurs, catégories, produits, listes et items."
)

# Création des tables au démarrage
@app.on_event("startup")
async def startup_event():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# Inclusion des routes avec tags pour Swagger
app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(categories.router, prefix="/categories", tags=["Categories"])
app.include_router(products.router, prefix="/products", tags=["Products"])
app.include_router(shopping_lists.router, prefix="/shopping-lists", tags=["Shopping Lists"])
app.include_router(shopping_items.router, prefix="/shopping-items", tags=["Shopping Items"])

@app.get("/", tags=["Root"])
async def root():
    return {"message": "Bienvenue sur ton API de gestion des courses 🚀"}