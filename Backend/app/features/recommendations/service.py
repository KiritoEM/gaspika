from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.features.shopping_lists.models import ShoppingList, ShoppingListItem  # CORRIGÉ
from app.features.products.models import FoodProduct  # CORRIGÉ
from app.features.categories.models import FoodCategory  # CORRIGÉ
from app.features.users.models import User  # CORRIGÉ

def compute_optimal_quantity(base_per_person: int | None, household_size: int) -> int:
    """
    Calcule la quantité optimale en fonction de la taille du ménage
    """
    if not base_per_person or base_per_person <= 0:
        base_per_person = 1
    extra_factor = 1.0
    if household_size > 4:
        extra_factor = 1.1
    return int(round(base_per_person * household_size * extra_factor))


class RecommendationService:
    def __init__(self, session: AsyncSession):
        self.db = session

    async def generate_weekly_list(
        self, 
        user_id: int, 
        week_number: int, 
        product_ids: list[int]
    ) -> ShoppingList:
        """
        Génère une liste de courses hebdomadaire
        """
        # Créer la liste de courses
        sl = ShoppingList(
            user_id=user_id, 
            week_number=week_number, 
            name=f"Semaine {week_number}", 
            status="draft"
        )
        self.db.add(sl)
        await self.db.flush()

        # Récupérer les informations de l'utilisateur
        result_user = await self.db.execute(select(User).where(User.id == user_id))
        user = result_user.scalar_one_or_none()
        household_size = user.household_size if user else 1

        items = []

        # Ajouter chaque produit à la liste
        for pid in product_ids:
            result_p = await self.db.execute(select(FoodProduct).where(FoodProduct.id == pid))
            p = result_p.scalar_one_or_none()
            if not p:
                continue
                
            qty = compute_optimal_quantity(p.recommended_quan or 1, household_size)

            result_cat = await self.db.execute(
                select(FoodCategory).where(FoodCategory.id == p.category_id)
            )
            cat = result_cat.scalar_one_or_none()

            item = ShoppingListItem(
                product_name=p.name,
                shopping_list_id=sl.id,
                estimated_quantity=qty,
                price=0,
                is_purchased=False,
                notes=None,
                storage_tips=p.storage_tips if hasattr(p, 'storage_tips') else None,
                category_id=cat.id if cat else None
            )
            self.db.add(item)
            items.append(item)

        await self.db.flush()
        
        # Calculer le coût total estimé
        sl.total_estimated_cost = sum([(item.price or 0) for item in items])
        
        return sl

    async def get_recommendations(
        self, 
        user_id: int, 
        category_id: int | None = None, 
        limit: int = 10
    ) -> list[FoodProduct]:
        """
        Récupère des recommandations de produits pour un utilisateur
        """
        query = select(FoodProduct).where(FoodProduct.is_available == True)
        
        if category_id:
            query = query.where(FoodProduct.category_id == category_id)
        
        # Exemple de logique de recommandation simple
        # En production, vous pourriez utiliser :
        # - Historique d'achats
        # - Préférences utilisateur
        # - Saisonnalité
        # - ML
        
        query = query.order_by(FoodProduct.unit_price).limit(limit)
        
        result = await self.db.execute(query)
        return result.scalars().all()

    async def suggest_alternatives(
        self, 
        product_id: int, 
        budget_multiplier: float = 1.0
    ) -> list[FoodProduct]:
        """
        Suggère des alternatives à un produit donné
        """
        # Récupérer le produit original
        result = await self.db.execute(
            select(FoodProduct).where(FoodProduct.id == product_id)
        )
        original = result.scalar_one_or_none()
        
        if not original:
            return []
        
        # Chercher des alternatives dans la même catégorie
        alternatives = await self.db.execute(
            select(FoodProduct)
            .where(FoodProduct.category_id == original.category_id)
            .where(FoodProduct.id != product_id)
            .where(FoodProduct.is_available == True)
            .order_by(FoodProduct.unit_price)
        )
        
        return alternatives.scalars().all()