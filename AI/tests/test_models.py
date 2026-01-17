"""
Script de test des modèles de prédiction - MVP Gaspik
Teste les modèles de conservation et de quantité d'aliments

Usage:
    python test_models.py
    
Auteur: Votre nom
Date: 2024
"""

import pickle
import numpy as np
import pandas as pd
from sklearn.metrics import mean_absolute_error, r2_score
import warnings
import os
warnings.filterwarnings('ignore')

def load_model(model_path):
    """Charge un modèle depuis un fichier pickle"""
    try:
        with open(model_path, 'rb') as f:
            model = pickle.load(f)
        return model
    except FileNotFoundError:
        raise FileNotFoundError(f"Modèle non trouvé: {model_path}")
    except Exception as e:
        raise Exception(f"Erreur lors du chargement du modèle: {e}")


def test_conservation_model():
    """Teste le modèle de conservation avec des cas réels"""
    print("="*80)
    print(" TEST MODÈLE CONSERVATION")
    print("="*80)
    
    # Charger le modèle
    print("\n Chargement du modèle...")
    
    MODEL_DIR = os.path.join(os.path.dirname(__file__), "../models")
    model_path = os.path.join(MODEL_DIR, "model_conservation_optimized.pkl")
    model = load_model(model_path)
    print("    Modèle chargé avec succès")
    
    # Cas de test réalistes
    print("\n Tests avec des cas réalistes...")
    
    test_cases = [
        {
            'nom': 'Lait',
            'features': {
                'humidite_relative': 80,
                'categorie_encoded': 50  # Laitier
            },
            'expected_range': (5, 15)  # Attendu: 7-14 jours
        },
        {
            'nom': 'Pomme',
            'features': {
                'humidite_relative': 85,
                'categorie_encoded': 25  # Fruit
            },
            'expected_range': (10, 30)  # Attendu: 14-30 jours
        },
        {
            'nom': 'Poulet',
            'features': {
                'humidite_relative': 80,
                'categorie_encoded': 10  # Viande
            },
            'expected_range': (1, 5)  # Attendu: 2-4 jours
        },
        {
            'nom': 'Riz sec',
            'features': {
                'humidite_relative': 60,
                'categorie_encoded': 500,  # Céréale
            },
            'expected_range': (300, 730)  # Attendu: 365-730 jours
        }
    ]
    
    passed = 0
    failed = 0
    
    for test in test_cases:
        # Préparer les features
        X = pd.DataFrame([test['features']])
        
        # Prédiction (en log)
        y_pred_log = model.predict(X)[0]
        
        # Reconversion en jours
        y_pred_days = np.expm1(y_pred_log)
        
        # Vérifier si dans la plage attendue
        in_range = test['expected_range'][0] <= y_pred_days <= test['expected_range'][1]
        status = " PASS" if in_range else " HORS PLAGE"
        
        print(f"\n   {status} - {test['nom']}")
        print(f"      Prédiction: {y_pred_days:.1f} jours")
        print(f"      Plage attendue: {test['expected_range'][0]}-{test['expected_range'][1]} jours")
        
        if in_range:
            passed += 1
        else:
            failed += 1
    
    print(f"\n Résultats: {passed}/{len(test_cases)} tests réussis")
    
    return passed == len(test_cases)


def test_aliments_model():
    """Teste le modèle de quantité d'aliments avec des cas réels"""
    print("\n" + "="*80)
    print("  TEST MODÈLE ALIMENTS")
    print("="*80)
    
    # Charger le modèle
    print("\n Chargement du modèle...")
    MODEL_DIR = os.path.join(os.path.dirname(__file__), "../models")
    model_path = os.path.join(MODEL_DIR, "model_aliments_FINAL.pkl")
    model = load_model(model_path)
    print("    Modèle chargé avec succès")
    
    # Cas de test réalistes
    print("\n Tests avec des cas réalistes...")
    
    test_cases = [
        {
            'nom': '2 personnes, 7 jours, riz',
            'features': {
                'nombre_personnes': 2,
                'duree_jours': 7,
                'personnes_x_duree': 2 * 7,
                'qte_par_pers_par_jour': 0.08,  # 80g par personne par repas
                'ratio_pers_duree': 2 / 8,
                'frequence_repas': 1.0,  # Déjeuner/dîner
                'categorie_encoded': 0.08,  # Céréale
                'unite_kg': 1,
                'unite_piece': 0
            },
            'expected_range': (0.8, 1.5)  # ~1.12 kg attendu (2 pers × 7j × 0.08)
        },
        {
            'nom': '4 personnes, 3 jours, poulet',
            'features': {
                'nombre_personnes': 4,
                'duree_jours': 3,
                'personnes_x_duree': 4 * 3,
                'qte_par_pers_par_jour': 0.15,  # 150g par personne
                'ratio_pers_duree': 4 / 4,
                'frequence_repas': 1.0,
                'categorie_encoded': 0.15,  # Viande
                'unite_kg': 1,
                'unite_piece': 0
            },
            'expected_range': (1.5, 2.5)  # ~1.8 kg attendu
        },
        {
            'nom': '1 personne, 30 jours, yaourt',
            'features': {
                'nombre_personnes': 1,
                'duree_jours': 30,
                'personnes_x_duree': 1 * 30,
                'qte_par_pers_par_jour': 1,  # 1 yaourt par jour
                'ratio_pers_duree': 1 / 31,
                'frequence_repas': 0.8,  # Petit-déjeuner (pas tous les jours)
                'categorie_encoded': 1,  # Laitier
                'unite_kg': 0,
                'unite_piece': 1
            },
            'expected_range': (20, 35)  # ~24 pièces attendues
        },
        {
            'nom': '6 personnes, 1 jour, tomates',
            'features': {
                'nombre_personnes': 6,
                'duree_jours': 1,
                'personnes_x_duree': 6 * 1,
                'qte_par_pers_par_jour': 0.1,  # 100g par personne
                'ratio_pers_duree': 6 / 2,
                'frequence_repas': 1.0,
                'categorie_encoded': 0.1,  # Légume
                'unite_kg': 1,
                'unite_piece': 0
            },
            'expected_range': (0.4, 0.8)  # ~0.6 kg attendu
        }
    ]
    
    passed = 0
    failed = 0
    
    for test in test_cases:
        # Préparer les features
        X = pd.DataFrame([test['features']])
        
        # Prédiction (peut être en log)
        y_pred = model.predict(X)[0]
        
        # Reconversion si log-transformé (détection automatique)
        if y_pred < 10:  # Probablement log-transformé
            y_pred_original = np.expm1(y_pred)
        else:
            y_pred_original = y_pred
        
        # Vérifier si dans la plage attendue
        in_range = test['expected_range'][0] <= y_pred_original <= test['expected_range'][1]
        status = " PASS" if in_range else " HORS PLAGE"
        
        print(f"\n   {status} - {test['nom']}")
        print(f"      Prédiction: {y_pred_original:.2f}")
        print(f"      Plage attendue: {test['expected_range'][0]}-{test['expected_range'][1]}")
        
        if in_range:
            passed += 1
        else:
            failed += 1
    
    print(f"\n Résultats: {passed}/{len(test_cases)} tests réussis")
    
    return passed == len(test_cases)


def test_model_robustness():
    """Teste la robustesse des modèles (valeurs extrêmes, NaN, etc.)"""
    print("\n" + "="*80)
    print(" TESTS DE ROBUSTESSE")
    print("="*80)
    

    MODEL_DIR = os.path.join(os.path.dirname(__file__), "../models")
    model_cons_path = os.path.join(MODEL_DIR, "model_conservation_optimized.pkl")
    model_alim_path = os.path.join(MODEL_DIR, "model_aliments_FINAL.pkl")
    model_cons = load_model(model_cons_path)
    model_alim = load_model(model_alim_path)
    
    tests_passed = True
    
    # Test 1: Valeurs extrêmes (conservation)
    print("\n Test valeurs extrêmes (Conservation)...")
    try:
        X_extreme = pd.DataFrame([{
            'humidite_relative': 100,
            'categorie_encoded': 1000
        }])
        pred = model_cons.predict(X_extreme)[0]
        pred_days = np.expm1(pred)
        print(f"    Gère les valeurs extrêmes (prédiction: {pred_days:.1f} jours)")
    except Exception as e:
        print(f"    Erreur avec valeurs extrêmes: {e}")
        tests_passed = False
    
    # Test 2: Cohérence (aliments)
    print("\n Test cohérence (Aliments)...")
    try:
        # 2 personnes devrait donner environ le double d'1 personne
        X_1p = pd.DataFrame([{
            'nombre_personnes': 1, 'duree_jours': 7, 'personnes_x_duree': 7,
            'qte_par_pers_par_jour': 0.1, 'ratio_pers_duree': 0.125,
            'frequence_repas': 1.0, 'categorie_encoded': 0.1,
            'unite_kg': 1, 'unite_piece': 0
        }])
        X_2p = pd.DataFrame([{
            'nombre_personnes': 2, 'duree_jours': 7, 'personnes_x_duree': 14,
            'qte_par_pers_par_jour': 0.1, 'ratio_pers_duree': 0.25,
            'frequence_repas': 1.0, 'categorie_encoded': 0.1,
            'unite_kg': 1, 'unite_piece': 0
        }])
        
        pred_1p = np.expm1(model_alim.predict(X_1p)[0]) if model_alim.predict(X_1p)[0] < 10 else model_alim.predict(X_1p)[0]
        pred_2p = np.expm1(model_alim.predict(X_2p)[0]) if model_alim.predict(X_2p)[0] < 10 else model_alim.predict(X_2p)[0]
        
        ratio = pred_2p / pred_1p
        is_coherent = 1.5 < ratio < 2.5  # Devrait être proche de 2
        
        if is_coherent:
            print(f"    Cohérence OK (1p: {pred_1p:.2f}, 2p: {pred_2p:.2f}, ratio: {ratio:.2f})")
        else:
            print(f"    Cohérence discutable (ratio: {ratio:.2f}, attendu: ~2.0)")
            tests_passed = False
    except Exception as e:
        print(f"    Erreur test cohérence: {e}")
        tests_passed = False
    
    # Test 3: Prédictions positives
    print("\n Test prédictions positives...")
    try:
        # Les prédictions ne doivent jamais être négatives
        X_test_cons = pd.DataFrame([{
            'humidite_relative': 85, 'categorie_encoded': 50
        }])
        X_test_alim = pd.DataFrame([{
            'nombre_personnes': 3, 'duree_jours': 5, 'personnes_x_duree': 15,
            'qte_par_pers_par_jour': 0.08, 'ratio_pers_duree': 0.5,
            'frequence_repas': 1.0, 'categorie_encoded': 0.08,
            'unite_kg': 1, 'unite_piece': 0
        }])
        
        pred_cons = np.expm1(model_cons.predict(X_test_cons)[0])
        pred_alim = np.expm1(model_alim.predict(X_test_alim)[0]) if model_alim.predict(X_test_alim)[0] < 10 else model_alim.predict(X_test_alim)[0]
        
        if pred_cons > 0 and pred_alim > 0:
            print(f"    Prédictions positives (cons: {pred_cons:.1f}j, alim: {pred_alim:.2f})")
        else:
            print(f"    Prédictions négatives détectées!")
            tests_passed = False
    except Exception as e:
        print(f"    Erreur test prédictions: {e}")
        tests_passed = False
    
    return tests_passed


def main():
    """Fonction principale de test"""
    print("\n" + "="*80)
    print(" SUITE DE TESTS - MODÈLES MVP GASPIK")
    print("="*80)
    print("\nCe script teste les modèles de prédiction:")
    print("   model_conservation_optimized.pkl")
    print("   model_aliments_FINAL.pkl")
    print("\n" + "="*80)
    
    all_tests_passed = True
    
    # Test Conservation
    try:
        conservation_passed = test_conservation_model()
        all_tests_passed = all_tests_passed and conservation_passed
    except Exception as e:
        print(f"\n ERREUR CRITIQUE - Conservation: {e}")
        all_tests_passed = False
    
    # Test Aliments
    try:
        aliments_passed = test_aliments_model()
        all_tests_passed = all_tests_passed and aliments_passed
    except Exception as e:
        print(f"\n ERREUR CRITIQUE - Aliments: {e}")
        all_tests_passed = False
    
    # Tests de robustesse
    try:
        robustness_passed = test_model_robustness()
        all_tests_passed = all_tests_passed and robustness_passed
    except Exception as e:
        print(f"\n ERREUR CRITIQUE - Robustesse: {e}")
        all_tests_passed = False
    
    # Résultat final
    print("\n" + "="*80)
    print(" RÉSULTAT FINAL")
    print("="*80)
    
    if all_tests_passed:
        print("\n TOUS LES TESTS SONT PASSÉS!")
        print(" Les modèles sont prêts pour la production")
        return 0
    else:
        print("\n CERTAINS TESTS ONT ÉCHOUÉ")
        print(" Vérifier les logs ci-dessus pour plus de détails")
        return 1


if __name__ == "__main__":
    exit_code = main()