import numpy as np
import pandas as pd
from fastapi import HTTPException
from .food_ml_schemas import FoodInput, FoodOutput         
from .food_ml_repository import FoodMLRepository 
from Backend.app.core.langchain_model import Model
from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

class FoodMlServices:                                       
    def __init__(self, repo: FoodMLRepository) -> None:     
        self.repo = repo
        self.llm = Model()()

    @staticmethod
    def _build_features(data: FoodInput) -> pd.DataFrame:   
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

        return pd.DataFrame([
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
        ])

    def predict(self, data: FoodInput) -> FoodOutput:      
        if not self.repo.is_loaded():
            raise HTTPException(status_code=503, detail="Modèle de quantité non disponible")

        try:
            features = self._build_features(data)
            prediction = self.repo.model.predict(features)[0]

            if prediction < 10: 
                quantite = np.expm1(prediction)
            else:
                quantite = prediction

            if data.unite.lower() == "piece":
                quantite = round(quantite)
            else:
                quantite = round(quantite, 2)
            
            template = """
                Tu es un expert en quantité des aliments. 
                Voici les prédictions de mon système :

                Catégorie de l'aliment: {categorie}
                Quantité de l'aliment prédite: {quantite}
                Unité de l'aliment: {unite}
                Nombre de personnes: {nombre_personnes}
                Durée de jours de la consommation: {duree_jours}

                Donne une interprétation détaillée et des recommandations pratiques.
            """
            prompt = PromptTemplate(
                input_variables=["categorie", "quantite", "unite", "nombre_personnes", "duree_jours"],
                template=template
            )
            chain = prompt | self.llm | StrOutputParser()

            return FoodOutput(                          
                food=data.food,                       
                quantite_recommandee=quantite,
                unite=data.unite,
                nombre_personnes=data.nombre_personnes,
                duree_jours=data.duree_jours,
                interpretation= chain.invoke({
                    "categorie": data.categorie,
                    "quantite": quantite,
                    "unite": data.unite,
                    "nombre_personnes": data.nombre_personnes,
                    "duree_jours": data.duree_jours
                })
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Erreur de prédiction: {str(e)}")
