def conservation_interpretation(duree_jours: float, categorie: str) -> str:
    if duree_jours < 3:
        return f"Très périssable : consommer rapidement (dans les {duree_jours:.0f} jours)"
    elif duree_jours < 7:
        return f"Périssable : consommer dans la semaine ({duree_jours:.0f} jours)"
    elif duree_jours < 30:
        return f"Conservation courte : bon pendant {duree_jours:.0f} jours"
    elif duree_jours < 90:
        return f"Conservation moyenne : {duree_jours:.0f} jours (environ {duree_jours/30:.0f} mois)"
    else:
        return f"Longue conservation : {duree_jours:.0f} jours (environ {duree_jours/30:.0f} mois)"
