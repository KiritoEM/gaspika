from pydantic import BaseModel, Field
from typing import Optional

class FoodInput(BaseModel):
    food: str = Field(..., description="Nom de l'aliment", example="Rice")
    nombre_personnes: int = Field(..., ge=1, le=20, description="Nombre de personnes", example=4)
    duree_jours: int = Field(..., ge=1, le=365, description="Durée en jours", example=7)
    type_repas: str = Field(..., description="Type: petit_dejeuner, dejeuner, diner, collation", example="dejeuner")
    categorie: str = Field(..., description="Catégorie: cereale, viande, poisson, legume, fruit, laitier", example="cereale")
    unite: str = Field(..., description="Unité: kg, L, piece", example="kg")


    class Config:
        schema_extra = {
            "example": {
                "food": "Rice",
                "nombre_personnes": 4,
                "duree_jours": 7,
                "type_repas": "dejeuner",
                "categorie": "cereale",
                "unite": "kg",
            }
        }


class FoodOutput(BaseModel):
    food: str
    quantite_recommandee: float = Field(..., description="Quantité recommandée en unité")
    unite: str
    nombre_personnes: int
    duree_jours: int
    prix_estime: Optional[float] = Field(None, description="Prix estimé")
    conservation_humidity: Optional[int] = Field(None, description="Taux conservation %")
    interpretation: str = Field(..., description="Conseil d'utilisation")


    class Config:
        schema_extra = {
            "example": {
                "food": "Rice",
                "quantite_recommandee": 0.5,
                "unite": "kg",
                "nombre_personnes": 4,
                "duree_jours": 7,
                "prix_estime": 2.50,
                "conservation_humidity": 85,
                "interpretation": "Portion standard pour 4 personnes pendant 7 jours. Stocker au sec.",
            }
        }


class FoodResponse(BaseModel):
    success: bool = True
    data: FoodOutput
    message: Optional[str] = None


    class Config:
        schema_extra = {
            "example": {
                "success": True,
                "data": {
                    "food": "Rice",
                    "quantite_recommandee": 0.5,
                    "unite": "kg",
                    "nombre_personnes": 4,
                    "duree_jours": 7,
                    "prix_estime": 2.50,
                    "conservation_humidity": 85,
                    "interpretation": "Portion standard pour 4 personnes"
                },
                "message": "Calcul terminé avec succès"
            }
        }
