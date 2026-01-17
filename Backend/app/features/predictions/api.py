from fastapi import APIRouter, Depends, HTTPException
from app.core.dependencies import require_user  # CORRIGÉ
from app.features.predictions.schemas import QuantityPredictionRequest, QuantityPredictionResponse  # CORRIGÉ
from app.features.predictions.service import ml_service  # CORRIGÉ

router = APIRouter(prefix="/predictions", tags=["predictions"], dependencies=[Depends(require_user)])

@router.post(
    "/quantity",
    response_model=QuantityPredictionResponse,
    summary="Prédire la quantité nécessaire",
    description="Utilise le modèle ML pour estimer la quantité d'aliment nécessaire"
)
async def predict_quantity(payload: QuantityPredictionRequest):
    try:
        category_code = ml_service.get_category_code(payload.category)
        
        quantity = ml_service.predict_quantity(
            nb_persons=payload.nb_persons,
            duration_days=payload.duration_days,
            qty_per_person_per_day=payload.qty_per_person_per_day,
            category_encoded=category_code,
            meal_frequency=payload.meal_frequency,
            unit_kg=payload.unit_kg
        )
        
        return QuantityPredictionResponse(
            quantity=quantity,
            unit="kg" if payload.unit_kg else "pièces",
            nb_persons=payload.nb_persons,
            duration_days=payload.duration_days
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erreur lors de la prédiction: {str(e)}"
        )