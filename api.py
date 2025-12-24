"""
API FastAPI pour les modèles de prédiction Gaspika
Endpoints : Conservation et Quantité d'aliments

Author: Votre équipe
Date: 2024
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import pickle
import numpy as np
import pandas as pd
from typing import Optional

# ==========================================
# CONFIGURATION DE L'API
# ==========================================

app = FastAPI(
    title="Gaspika ML API",
    description="API de prédiction pour la conservation des aliments et les quantités recommandées",
    version="1.0.0"
)

# CORS (pour permettre les requêtes depuis un frontend)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifier les domaines autorisés
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# CHARGEMENT DES MODÈLES
# ==========================================

# MODÈLE CONSERVATION OPTIMISÉ
# Version avec feature selection : 2 features au lieu de 10
# Performances améliorées : R²=0.9820 (au lieu de 0.9526)
# MAE amélioré : 28.82 jours (au lieu de 45.57)

try:
    with open('models/model_conservation_optimized.pkl', 'rb') as f:
        model_conservation = pickle.load(f)
    print(" Modèle Conservation chargé")
except Exception as e:
    print(f" Erreur chargement modèle Conservation: {e}")
    model_conservation = None

try:
    with open('models/model_aliments_FINAL.pkl', 'rb') as f:
        model_aliments = pickle.load(f)
    print(" Modèle Aliments chargé")
except Exception as e:
    print(f" Erreur chargement modèle Aliments: {e}")
    model_aliments = None

# ==========================================
# MODÈLES DE DONNÉES (Pydantic)
# ==========================================

class ConservationInput(BaseModel):
    """Input pour la prédiction de conservation"""
    humidite_relative: float = Field(..., description="Humidité relative en %", example=80)
    categorie: str = Field(..., description="Catégorie: fruit, legume, laitier, viande, poisson, cereale", example="laitier")
    
    class Config:
        schema_extra = {
            "example": {
                "humidite_relative": 80,
                "categorie": "laitier"
            }
        }


class ConservationOutput(BaseModel):
    """Output de la prédiction de conservation"""
    duree_conservation_jours: float = Field(..., description="Durée de conservation prédite en jours")
    categorie: str
    interpretation: str = Field(..., description="Interprétation de la prédiction")


class AlimentsInput(BaseModel):
    """Input pour la prédiction de quantité"""
    aliment: str = Field(..., description="Nom de l'aliment", example="Riz")
    nombre_personnes: int = Field(..., ge=1, le=20, description="Nombre de personnes", example=4)
    duree_jours: int = Field(..., ge=1, le=365, description="Durée en jours", example=7)
    type_repas: str = Field(..., description="Type: petit_dejeuner, dejeuner, diner, collation", example="dejeuner")
    categorie: str = Field(..., description="Catégorie: cereale, viande, poisson, legume, fruit, laitier", example="cereale")
    unite: str = Field(..., description="Unité: kg, L, piece", example="kg")
    
    class Config:
        schema_extra = {
            "example": {
                "aliment": "Riz",
                "nombre_personnes": 4,
                "duree_jours": 7,
                "type_repas": "dejeuner",
                "categorie": "cereale",
                "unite": "kg"
            }
        }


class AlimentsOutput(BaseModel):
    """Output de la prédiction de quantité"""
    aliment: str
    quantite_recommandee: float = Field(..., description="Quantité recommandée")
    unite: str
    nombre_personnes: int
    duree_jours: int
    interpretation: str


class HealthCheck(BaseModel):
    """Status de santé de l'API"""
    status: str
    model_conservation: str
    model_aliments: str
    version: str


# ==========================================
# FONCTIONS UTILITAIRES
# ==========================================

def calculer_features_conservation(data: ConservationInput) -> pd.DataFrame:
    """Calcule les features pour le modèle de conservation"""
    
    # Encodage de la catégorie (target encoding approximatif)
    categorie_encoding = {
        'fruit': 25,
        'legume': 20,
        'laitier': 50,
        'viande': 10,
        'poisson': 8,
        'cereale': 500
    }
    
    # Créer le DataFrame avec toutes les features
    features = pd.DataFrame([{
        'humidite_relative': data.humidite_relative,
        'categorie_encoded': categorie_encoding.get(data.categorie.lower(), 50)
    }])
    
    return features


def calculer_features_aliments(data: AlimentsInput) -> pd.DataFrame:
    """Calcule les features pour le modèle de quantité"""
    
    # Encodage de la catégorie (target encoding approximatif)
    categorie_encoding = {
        'cereale': 0.08,
        'viande': 0.15,
        'poisson': 0.12,
        'legume': 0.10,
        'fruit': 0.15,
        'laitier': 1.0
    }
    
    # Fréquence des repas
    frequence_repas_map = {
        'petit_dejeuner': 0.8,
        'dejeuner': 1.0,
        'diner': 1.0,
        'collation': 0.5
    }
    
    # Features dérivées
    personnes_x_duree = data.nombre_personnes * data.duree_jours
    qte_base = categorie_encoding.get(data.categorie.lower(), 0.1)
    qte_par_pers_par_jour = qte_base
    ratio_pers_duree = data.nombre_personnes / (data.duree_jours + 1)
    frequence_repas = frequence_repas_map.get(data.type_repas.lower(), 1.0)
    
    # Encodage de l'unité (one-hot)
    unite_kg = 1 if data.unite.lower() == 'kg' else 0
    unite_piece = 1 if data.unite.lower() == 'piece' else 0
    
    # Créer le DataFrame
    features = pd.DataFrame([{
        'nombre_personnes': data.nombre_personnes,
        'duree_jours': data.duree_jours,
        'personnes_x_duree': personnes_x_duree,
        'qte_par_pers_par_jour': qte_par_pers_par_jour,
        'ratio_pers_duree': ratio_pers_duree,
        'frequence_repas': frequence_repas,
        'categorie_encoded': qte_base,
        'unite_kg': unite_kg,
        'unite_piece': unite_piece
    }])
    
    return features


def interpreter_conservation(duree_jours: float, categorie: str) -> str:
    """Génère une interprétation de la durée de conservation"""
    if duree_jours < 3:
        return f" Très périssable : consommer rapidement (dans les {duree_jours:.0f} jours)"
    elif duree_jours < 7:
        return f" Périssable : consommer dans la semaine ({duree_jours:.0f} jours)"
    elif duree_jours < 30:
        return f" Conservation courte : bon pendant {duree_jours:.0f} jours"
    elif duree_jours < 90:
        return f" Conservation moyenne : {duree_jours:.0f} jours (environ {duree_jours/30:.0f} mois)"
    else:
        return f" Longue conservation : {duree_jours:.0f} jours (environ {duree_jours/30:.0f} mois)"


def interpreter_quantite(quantite: float, unite: str, nb_pers: int, duree: int) -> str:
    """Génère une interprétation de la quantité"""
    qte_par_pers = quantite / nb_pers
    qte_par_jour = quantite / duree
    
    return f"Soit {qte_par_pers:.2f} {unite} par personne, ou {qte_par_jour:.2f} {unite} par jour"


# ==========================================
# ENDPOINTS
# ==========================================

@app.get("/", response_model=HealthCheck)
async def root():
    """Endpoint de santé de l'API"""
    return {
        "status": "online",
        "model_conservation": "loaded" if model_conservation else "error",
        "model_aliments": "loaded" if model_aliments else "error",
        "version": "1.0.0"
    }


@app.post("/predict/conservation", response_model=ConservationOutput)
async def predict_conservation(data: ConservationInput):
    """
    Prédit la durée de conservation d'un aliment
    
    - **humidite_relative**: Humidité en % (ex: 80)
    - **categorie**: fruit, legume, laitier, viande, poisson, cereale
    """
    
    if model_conservation is None:
        raise HTTPException(status_code=503, detail="Modèle de conservation non disponible")
    
    try:
        # Calculer les features
        features = calculer_features_conservation(data)
        
        # Prédiction (en log)
        prediction_log = model_conservation.predict(features)[0]
        
        # Reconvertir en jours
        duree_jours = np.expm1(prediction_log)
        
        # Arrondir à 1 décimale
        duree_jours = round(duree_jours, 1)
        
        # Interprétation
        interpretation = interpreter_conservation(duree_jours, data.categorie)
        
        return ConservationOutput(
            duree_conservation_jours=duree_jours,
            categorie=data.categorie,
            interpretation=interpretation
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur de prédiction: {str(e)}")


@app.post("/predict/quantite", response_model=AlimentsOutput)
async def predict_quantite(data: AlimentsInput):
    """
    Prédit la quantité recommandée d'un aliment
    
    - **aliment**: Nom de l'aliment
    - **nombre_personnes**: Nombre de personnes (1-20)
    - **duree_jours**: Durée en jours (1-365)
    - **type_repas**: petit_dejeuner, dejeuner, diner, collation
    - **categorie**: cereale, viande, poisson, legume, fruit, laitier
    - **unite**: kg, L, piece
    """
    
    if model_aliments is None:
        raise HTTPException(status_code=503, detail="Modèle de quantité non disponible")
    
    try:
        # Calculer les features
        features = calculer_features_aliments(data)
        
        # Prédiction (peut être en log)
        prediction = model_aliments.predict(features)[0]
        
        # Reconvertir si log-transformé
        if prediction < 10:  # Probablement log
            quantite = np.expm1(prediction)
        else:
            quantite = prediction
        
        # Arrondir selon l'unité
        if data.unite.lower() == 'piece':
            quantite = round(quantite)
        else:
            quantite = round(quantite, 2)
        
        # Interprétation
        interpretation = interpreter_quantite(
            quantite, 
            data.unite, 
            data.nombre_personnes, 
            data.duree_jours
        )
        
        return AlimentsOutput(
            aliment=data.aliment,
            quantite_recommandee=quantite,
            unite=data.unite,
            nombre_personnes=data.nombre_personnes,
            duree_jours=data.duree_jours,
            interpretation=interpretation
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur de prédiction: {str(e)}")


@app.get("/health")
async def health_check():
    """Endpoint de santé détaillé"""
    return {
        "status": "healthy",
        "models": {
            "conservation": {
                "loaded": model_conservation is not None,
                "performance": {
                    "R2": 0.9820,
                    "MAE_jours": 28.82,
                    "features": 2,
                    "note": "Modèle optimisé avec feature selection"
                }
            },
            "aliments": {
                "loaded": model_aliments is not None,
                "performance": {
                    "R2": 0.9826,
                    "MAE": 1.02
                }
            }
        }
    }


# ==========================================
# LANCEMENT DE L'API
# ==========================================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)