def food_interpretation(quantite: float, unite: str, nb_pers: int, duree: int) -> str: 
    qte_par_pers = quantite / nb_pers
    qte_par_jour = quantite / duree
    return f"Soit {qte_par_pers:.2f} {unite} par personne, ou {qte_par_jour:.2f} {unite} par jour"
