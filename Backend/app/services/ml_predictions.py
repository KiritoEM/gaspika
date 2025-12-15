import pickle
import numpy as np
import pandas as pd
from pathlib import Path

class MLPredictionService:
    def __init__(self):
        self.models_path = Path("models")
        self.aliments_model = self._load_model("model_aliments_FINAL.pkl")

    def _load_model(self, filename: str):
        path = self.models_path / filename
        with open(path, "rb") as f:
            return pickle.load(f)

    def predict_quantity(
        self,
        nb_persons: int,
        duration_days: int,
        qty_per_person_per_day: float,
        category_encoded: float,
        meal_frequency: float,
        unit_kg: bool,
    ) -> float:
        features = pd.DataFrame([
            {
                "nombre_personnes": nb_persons,
                "duree_jours": duration_days,
                "personnes_x_duree": nb_persons * duration_days,
                "qte_par_pers_par_jour": qty_per_person_per_day,
                "ratio_pers_duree": nb_persons / (duration_days + 1),
                "frequence_repas": meal_frequency,
                "categorie_encoded": category_encoded,
                "unite_kg": int(unit_kg),
                "unite_piece": int(not unit_kg),
            }
        ])

        y_pred = self.aliments_model.predict(features)[0]
        quantity = np.expm1(y_pred) if y_pred < 10 else y_pred
        return round(max(quantity, 0.01), 2)

    def get_category_code(self, category: str) -> float:
        mapping = {
            "viande": 10,
            "volaille": 15,
            "poisson": 20,
            "fruit": 25,
            "legume": 30,
            "fromage": 40,
            "laitier": 50,
            "yaourt": 55,
            "oeuf": 60,
            "pain": 70,
            "cereale": 80,
            "riz": 85,
            "pates": 90,
            "legumineuse": 100,
            "condiment": 200,
            "conserve": 300,
            "surgele": 400,
            "sec": 500,
        }
        return mapping.get(category.lower(), 50)


ml_service = MLPredictionService()
