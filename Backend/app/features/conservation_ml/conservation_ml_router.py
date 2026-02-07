from fastapi import APIRouter

from .conservation_ml_schemas import ConservationInput, ConservationOutput
from .conservation_ml_repository import ConservationMLRepository
from .conservation_ml_service import ConservationMLService

conservation_ml_router = APIRouter(prefix="/predict", tags=["conservation ML"])

_repo = ConservationMLRepository()
_service = ConservationMLService(_repo)


@conservation_ml_router.post("/conservation", response_model=ConservationOutput)
async def predict_conservation(data: ConservationInput):
    return _service.predict(data)
