from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from app.features.users.user_router import user_router
from app.features.auth.auth_router import auth_router
from app.features.shopping_lists.shopping_list_router import shopping_list_router
from app.features.categories.category_router import category_router
from app.features.shopping_items.shopping_items_router import shopping_items_router
from app.features.aliments_ml.aliments_ml_router import alimentsRouter
from app.features.conservation_ml.conservation_ml_router import conservationRouter

app = FastAPI(
    title="Gaspika API",
    description="API pour l'application Gaspika",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # à restreindre en prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


api_router = APIRouter(prefix="/api")
api_router.include_router(auth_router)
api_router.include_router(shopping_list_router)
api_router.include_router(category_router)
api_router.include_router(shopping_items_router)
api_router.include_router(user_router)
api_router.include_router(alimentsRouter)
api_router.include_router(conservationRouter)


app.include_router(api_router)

@app.get("/")
async def root():
    return {"message": "Server is running !!!"}

@app.get("/health")
async def root():
  return {"status": "healthy"}
