## 🤖 Modèles ML (Conservation & Quantités)

### Performances
- **Conservation** : R²=95.26%, MAE=45.57 jours
- **Quantités** : R²=98.26%, MAE=1.02 unités

### Utilisation
```bash
# Tests
python tests/test_models.py

# Prédiction Conservation
import pickle
with open('models/model_conservation_FINAL.pkl', 'rb') as f:
    model = pickle.load(f)
```

### Structure
```
models/               # Modèles entraînés
├── model_conservation_FINAL.pkl
└── model_aliments_FINAL.pkl

tests/                # Scripts de test
└── test_models.py
```