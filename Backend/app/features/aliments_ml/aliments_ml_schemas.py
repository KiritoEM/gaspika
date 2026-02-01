from pydantic import BaseModel, Field


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
                "unite": "kg",
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
