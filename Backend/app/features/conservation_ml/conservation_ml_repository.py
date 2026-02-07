import pickle
from pathlib import Path
from typing import Any, Optional


class ConservationMLRepository:
    def __init__(self, model_path: Optional[str] = None) -> None:
        base = Path(__file__).resolve().parents[2] / "models"
        path = Path(model_path) if model_path else base / "model_conservation_optimized.pkl"
        self.model = self._load_model(path)

    @staticmethod
    def _load_model(path: Path) -> Optional[Any]:
        try:
            with open(path, "rb") as f:
                model = pickle.load(f)
                print("Modèle Conservation chargé")
                return model
        except Exception as e:
            print(f"Erreur chargement modèle Conservation: {e}")
            return None

    def is_loaded(self) -> bool:
        return self.model is not None
