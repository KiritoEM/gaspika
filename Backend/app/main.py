# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

# Import des routeurs de chaque feature
from app.features.auth.api import router as auth_router
from app.features.users.api import router as users_router
from app.features.categories.api import router as categories_router
from app.features.products.api import router as products_router
from app.features.shopping_lists.api import router as shopping_lists_router
from app.features.shopping_items.api import router as shopping_items_router
from app.features.predictions.api import router as predictions_router

# Import pour les migrations automatiques (optionnel)
from app.core.database import engine, Base

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API pour gérer les courses : utilisateurs, catégories, produits, listes et prédictions.",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Création des tables au démarrage (optionnel - utilisez Alembic en production)
@app.on_event("startup")
async def startup_event():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("Database tables created/verified")

# Inclure tous les routeurs avec leurs préfixes
app.include_router(auth_router, prefix="/api/auth", tags=["auth"])
app.include_router(users_router, prefix="/api/users", tags=["users"])
app.include_router(categories_router, prefix="/api/categories", tags=["categories"])
app.include_router(products_router, prefix="/api/products", tags=["products"])
app.include_router(shopping_lists_router, prefix="/api/shopping-lists", tags=["shopping-lists"])
app.include_router(shopping_items_router, prefix="/api/shopping-items", tags=["shopping-items"])
app.include_router(predictions_router, prefix="/api/predictions", tags=["predictions"])

# Route racine
@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "Bienvenue sur l'API Gaspika ",
        "version": settings.VERSION,
        "docs": "/docs" if settings.DEBUG else "disabled",
        "endpoints": [
            "/api/auth - Authentification",
            "/api/users - Gestion utilisateurs",
            "/api/categories - Catégories d'aliments",
            "/api/products - Produits alimentaires",
            "/api/shopping-lists - Listes de courses",
            "/api/shopping-items - Items des listes",
            "/api/predictions - Prédictions ML"
        ]
    }

# Health check
@app.get("/health", tags=["Health"])
async def health_check():
    return {"status": "healthy", "service": "gaspika-api"}