from fastapi import FastAPI
from app.database import Base, engine
from app.routers import auth, users, categories, products, shopping_lists, shopping_items

app = FastAPI(title="Grocery Planner API")

# Création des tables au démarrage
@app.on_event("startup")
async def startup_event():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# Inclusion des routes
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(categories.router)
app.include_router(products.router)
app.include_router(shopping_lists.router)
app.include_router(shopping_items.router)

@app.get("/")
async def root():
    return {"message": "Bienvenue sur ton API de gestion des courses 🚀"}