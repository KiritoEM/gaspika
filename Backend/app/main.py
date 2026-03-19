import logging
from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from app.features.food_ml import food_ml_router
from app.features.users.user_router import user_router
from app.features.auth.auth_router import auth_router
from app.features.shopping_lists.shopping_list_router import shopping_list_router
from app.features.categories.category_router import category_router
from app.features.shopping_items.shopping_items_router import shopping_items_router
from app.features.food_ml.food_ml_router import food_ml_router
from app.features.conservation_ml.conservation_ml_router import conservation_ml_router
from app.features.devices.device_router import device_router
from contextlib import asynccontextmanager
from app.core.scheduler import run_jobs, scheduler

logging.basicConfig(
    level=logging.INFO
)
logger = logging.getLogger(__name__) 

# cron jobs  
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Running jobs...")
    
    await run_jobs()               
    yield
    
    logger.info("Stopping jobs...")
    scheduler.shutdown()    

app = FastAPI(
    title="Gaspika API",
    description="API pour l'application Gaspika",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True
)


api_router = APIRouter(prefix="/api")
api_router.include_router(auth_router)
api_router.include_router(shopping_list_router)
api_router.include_router(category_router)
api_router.include_router(shopping_items_router)
api_router.include_router(user_router)
api_router.include_router(food_ml_router)
api_router.include_router(conservation_ml_router)
api_router.include_router(device_router)

app.include_router(api_router)

@app.get("/")
async def root():
    return {"message": "Server is running !!!"}

@app.get("/health")
async def root():
  return {"status": "healthy"}
