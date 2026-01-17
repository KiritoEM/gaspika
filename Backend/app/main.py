from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "API Restructurée", "version": settings.VERSION}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Les imports des routeurs seront ajoutés ici progressivement
# from app.features.auth.api import router as auth_router
# app.include_router(auth_router, prefix="/auth", tags=["auth"])
