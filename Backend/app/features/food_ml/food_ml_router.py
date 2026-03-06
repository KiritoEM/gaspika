from typing import Annotated
from fastapi import APIRouter, Depends
from .food_ml_schemas import FoodInput, FoodOutput 
from .food_ml_repository import FoodMLRepository   
from .food_ml_service import FoodMlServices       

food_ml_router = APIRouter(prefix="/predict", tags=["Food Prediction"]) 

def get_food_services() -> FoodMlServices:           
    repot = FoodMLRepository()                         
    return FoodMlServices(repot)

@food_ml_router.post(
    "/quantite",
    response_model=FoodOutput,                        
    summary="Prédire la quantité recommandée d'un aliment",
    responses={
        200: {"description": "Prédiction effectuée avec succès"},
        503: {"description": "Modèle non disponible"},
        500: {"description": "Erreur interne de prédiction"},
    },
    status_code=200,
)
async def predict_quantite(
    payload: FoodInput,                                
    service: Annotated[FoodMlServices, Depends(get_food_services)], 
):
    result = service.predict(payload)
    return result
