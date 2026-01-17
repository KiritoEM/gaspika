from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware

from app.features.auth.router import authRouter

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

app.include_router(api_router)

@app.get("/")
async def root():
    return {"message": "Server is running !!!"}

@app.get("/health")
async def root():
  return {"status": "healthy"}
