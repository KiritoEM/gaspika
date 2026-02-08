import numpy as np
import pandas as pd
from fastapi import HTTPException

from .conservation_ml_schemas import ConservationInput, ConservationOutput
from .conservation_ml_repository import ConservationMLRepository
from Backend.app.core.langchain_model import Model
from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

class ConservationMLService:
    def __init__(self, repo: ConservationMLRepository) -> None:
        self.repo = repo
        self.llm = Model()()

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
            template = """
                Tu es un expert en conservation des aliments. 
                Voici les prédictions de mon système :

                Catégorie de l'aliment: {categorie}
                Durée de conservation prédite: {duree} jours
                Humidité relative: {humidite}

                Donne une interprétation détaillée et des recommandations pratiques.
            """
            prompt = PromptTemplate(
                input_variables=["categorie", "duree", "humidite"],
                template=template
            )
            chain = prompt | self.llm | StrOutputParser()

            return ConservationOutput(
                duree_conservation_jours=duree_jours,
                categorie=data.categorie,
                interpretation=chain.invoke({
                    "categorie": data.categorie,
                    "duree": duree_jours,
                    "humidite": data.humidite_relative
                }),
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Erreur de prédiction: {str(e)}")
