from pydantic import BaseModel, Field


class ConservationInput(BaseModel):
    food_name: str = Field(..., description="Nom du produit", example="lait"),
    humidite_relative: float = Field(..., description="Humidité relative en %", example=80)
    categorie: str = Field(
        ...,
        description="Catégorie: fruit, legume, laitier, viande, poisson, cereale",
        example="laitier",
    )

    class Config:
        schema_extra = {
            "example": {
                "humidite_relative": 80,
                "categorie": "laitier",
            }
        }


class ConservationOutput(BaseModel):
    duree_conservation_jours: float = Field(..., description="Durée de conservation prédite en jours")
    categorie: str
    interpretation: str = Field(..., description="Interprétation de la prédiction")
