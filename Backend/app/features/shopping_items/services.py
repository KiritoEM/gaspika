import random
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, extract
from app.features.shopping_lists.repository import ShoppingListRepository
from app.features.shopping_items.repository import ShoppingItemRepository
from app.features.shopping_items.schemas import ShoppingListItemCreate, ShoppingListItemUpdate, ShoppingListItemOut

class ShoppingItemService:
    def __init__(self, session: AsyncSession):
        self.item_repo = ShoppingItemRepository(session)
        self.list_repo = ShoppingListRepository(session)

    async def get_items_in_list(self, list_id: int, user_id: int, category_id: int | None = None) -> list[ShoppingListItemOut]:
        # Vérifier que la liste appartient à l'utilisateur
        shopping_list = await self.list_repo.get_by_id_and_user(list_id, user_id)
        if not shopping_list:
            raise ValueError("List not found or access denied")
        
        items = await self.item_repo.get_by_list_id(list_id)
        if category_id:
            items = [item for item in items if item.category_id == category_id]
        
        return [ShoppingListItemOut.model_validate(item) for item in items]

    async def get_week_items(self, week_number: int, user_id: int, year: int = None) -> list[ShoppingListItemOut]:
        if year is None:
            year = datetime.now().year
            
        # Trouver la liste pour cette semaine
        shopping_list = await self.list_repo.get_by_week_and_user(week_number, user_id, year)
        if not shopping_list:
            return []
        
        # Récupérer les items non achetés
        items = await self.item_repo.get_by_list_id(shopping_list.id)
        unpurchased = [item for item in items if not item.is_purchased]
        
        # Retourner 5 items aléatoires ou tous si moins de 5
        if len(unpurchased) <= 5:
            return [ShoppingListItemOut.model_validate(item) for item in unpurchased]
        
        random_items = random.sample(unpurchased, 5)
        return [ShoppingListItemOut.model_validate(item) for item in random_items]

    async def add_item_to_list(self, list_id: int, user_id: int, item_data: ShoppingListItemCreate) -> ShoppingListItemOut:
        # Vérifier que la liste appartient à l'utilisateur
        shopping_list = await self.list_repo.get_by_id_and_user(list_id, user_id)
        if not shopping_list:
            raise ValueError("List not found or access denied")
        
        # Créer l'item
        item = await self.item_repo.create(item_data.model_dump())
        return ShoppingListItemOut.model_validate(item)

    async def count_unpurchased_items(self, week_number: int, user_id: int, category_id: int | None = None) -> dict:
        year = datetime.now().year
        shopping_list = await self.list_repo.get_by_week_and_user(week_number, user_id, year)
        
        if not shopping_list:
            return {"count": 0}
        
        count = await self.item_repo.count_unpurchased_by_list(shopping_list.id, category_id)
        return {"count": count}