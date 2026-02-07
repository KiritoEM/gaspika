import numpy as np
import pandas as pd
from fastapi import HTTPException

from .conservation_ml_schemas import ConservationInput, ConservationOutput
from .conservation_ml_repository import ConservationMLRepository
from .conservation_ml_interpretation import conservation_interpretation


class ConservationMLService:
    def __init__(self, repo: ConservationMLRepository) -> None:
        self.repo = repo

    @staticmethod
    def _build_features(data: ConservationInput) -> pd.DataFrame:
        categorie_encoding = {
            "fruit": 25,
            "legume": 20,
            "laitier": 50,
            "viande": 10,
            "poisson": 8,
            "cereale": 500,
        }

        return pd.DataFrame(
            [
                {
                    "humidite_relative": data.humidite_relative,
                    "categorie_encoded": categorie_encoding.get(data.categorie.lower(), 50),
                }
            ]
        )

    def predict(self, data: ConservationInput) -> ConservationOutput:
        if not self.repo.is_loaded():
            raise HTTPException(status_code=503, detail="Modèle de conservation non disponible")

        try:
            features = self._build_features(data)
            prediction_log = self.repo.model.predict(features)[0]
            duree_jours = np.expm1(prediction_log)
            duree_jours = round(duree_jours, 1)

            return ConservationOutput(
                duree_conservation_jours=duree_jours,
                categorie=data.categorie,
                interpretation=conservation_interpretation(duree_jours, data.categorie),
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Erreur de prédiction: {str(e)}")
