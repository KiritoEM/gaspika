from typing import Annotated

from fastapi import APIRouter, Depends
from .conservation_ml_schemas import ConservationInput, ConservationOutput
from .conservation_ml_repository import ConservationMLRepository
from .conservation_ml_services import ConservationMLServices

conservationRouter = APIRouter(prefix="/predict", tags=["Conservation"])


def get_conservation_services() -> ConservationMLServices:
    repo = ConservationMLRepository()
    return ConservationMLServices(repo)


@conservationRouter.post(
    "/conservation",
    response_model=ConservationOutput,
    summary="Prédire la durée de conservation d'un aliment",
    responses={
        200: {"description": "Prédiction effectuée avec succès"},
        503: {"description": "Modèle non disponible"},
        500: {"description": "Erreur interne de prédiction"},
    },
    status_code=200,
)
async def predict_conservation(
    payload: ConservationInput,
    service: Annotated[ConservationMLServices, Depends(get_conservation_services)],
):
    result = service.predict(payload)
    return result
