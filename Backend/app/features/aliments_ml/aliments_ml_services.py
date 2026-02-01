import numpy as np
import pandas as pd
from fastapi import HTTPException

from .aliments_ml_schemas import AlimentsInput, AlimentsOutput
from .aliments_ml_repository import AlimentsMLRepository
from .aliments_ml_interpretation import aliments_interpretation


class AlimentsMLServices:
    def __init__(self, repo: AlimentsMLRepository) -> None:
        self.repo = repo

    @staticmethod
    def _build_features(data: AlimentsInput) -> pd.DataFrame:
        """Reprend ta logique calculer_features_aliments."""
        categorie_encoding = {
            "cereale": 0.08,
            "viande": 0.15,
            "poisson": 0.12,
            "legume": 0.10,
            "fruit": 0.15,
            "laitier": 1.0,
        }

        frequence_repas_map = {
            "petit_dejeuner": 0.8,
            "dejeuner": 1.0,
            "diner": 1.0,
            "collation": 0.5,
        }

        personnes_x_duree = data.nombre_personnes * data.duree_jours
        qte_base = categorie_encoding.get(data.categorie.lower(), 0.1)
        qte_par_pers_par_jour = qte_base
        ratio_pers_duree = data.nombre_personnes / (data.duree_jours + 1)
        frequence_repas = frequence_repas_map.get(data.type_repas.lower(), 1.0)

        unite_kg = 1 if data.unite.lower() == "kg" else 0
        unite_piece = 1 if data.unite.lower() == "piece" else 0

        return pd.DataFrame(
            [
                {
                    "nombre_personnes": data.nombre_personnes,
                    "duree_jours": data.duree_jours,
                    "personnes_x_duree": personnes_x_duree,
                    "qte_par_pers_par_jour": qte_par_pers_par_jour,
                    "ratio_pers_duree": ratio_pers_duree,
                    "frequence_repas": frequence_repas,
                    "categorie_encoded": qte_base,
                    "unite_kg": unite_kg,
                    "unite_piece": unite_piece,
                }
            ]
        )

    def predict(self, data: AlimentsInput) -> AlimentsOutput:
        if not self.repo.is_loaded():
            raise HTTPException(status_code=503, detail="Modèle de quantité non disponible")

        try:
            features = self._build_features(data)
            prediction = self.repo.model.predict(features)[0]

            if prediction < 10:  # cas log-transformé
                quantite = np.expm1(prediction)
            else:
                quantite = prediction

            if data.unite.lower() == "piece":
                quantite = round(quantite)
            else:
                quantite = round(quantite, 2)

            return AlimentsOutput(
                aliment=data.aliment,
                quantite_recommandee=quantite,
                unite=data.unite,
                nombre_personnes=data.nombre_personnes,
                duree_jours=data.duree_jours,
                interpretation=aliments_interpretation(
                    quantite,
                    data.unite,
                    data.nombre_personnes,
                    data.duree_jours,
                ),
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Erreur de prédiction: {str(e)}")
