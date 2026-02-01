from typing import Annotated

from fastapi import APIRouter, Depends
from .aliments_ml_schemas import AlimentsInput, AlimentsOutput
from .aliments_ml_repository import AlimentsMLRepository
from .aliments_ml_services import AlimentsMLServices

alimentsRouter = APIRouter(prefix="/predict", tags=["Aliments"])


def get_aliments_services() -> AlimentsMLServices:
    repo = AlimentsMLRepository()
    return AlimentsMLServices(repo)


@alimentsRouter.post(
    "/quantite",
    response_model=AlimentsOutput,
    summary="Prédire la quantité recommandée d'un aliment",
    responses={
        200: {"description": "Prédiction effectuée avec succès"},
        503: {"description": "Modèle non disponible"},
        500: {"description": "Erreur interne de prédiction"},
    },
    status_code=200,
)
async def predict_quantite(
    payload: AlimentsInput,
    service: Annotated[AlimentsMLServices, Depends(get_aliments_services)],
):
    result = service.predict(payload)
    return result
