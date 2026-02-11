import numpy as np
import pandas as pd
from fastapi import HTTPException

from .conservation_ml_schemas import ConservationInput, ConservationOutput
from .conservation_ml_repository import ConservationMLRepository
from app.core.langchain_model import Model
from langchain_core.prompts import PromptTemplate
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
                Tu es un ami de confiance qui sait comment bien conserver les aliments.
                Tu parles simplement, comme dans une discussion du quotidien, sans ton scolaire ni phrases artificielles.

                Contexte :
                - Aliment : {name}
                - Catégorie : {categorie}
                - Durée estimée : {duree} jours
                - Humidité ambiante : {humidite} %

                Consigne :
                Donne un seul conseil en une phrase, fluide et naturelle, qui explique :
                - où garder l’aliment et dans quelles conditions,
                - comment le protéger au quotidien,
                - à quel moment il faut s’en débarrasser, en décrivant des signes concrets (odeur, texture, apparence).

                Style attendu :
                - Tutoie, parle spontanément
                - Utilise des verbes simples du quotidien (mets, garde, range, jette, enlève)
                - Pas de vocabulaire technique ni de phrases rigides
                - Le conseil doit sonner comme quelque chose que tu dirais vraiment à un proche
                - 40 à 50 mots maximum

                Contraintes :
                - Pas de listes
                - Pas de durées chiffrées
                - Pas de conseils supplémentaires
                - Une seule phrase
                - Français uniquement
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
                    "name": data.food_name,
                    "categorie": data.categorie,
                    "duree": duree_jours,
                    "humidite": data.humidite_relative
                }),
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Erreur de prédiction: {str(e)}")
