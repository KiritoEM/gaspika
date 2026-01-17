from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.features.shopping_lists.repository import ShoppingListRepository
from app.features.recommendations.service import RecommendationService
from app.features.shopping_lists.schemas import ShoppingListCreate, ShoppingListUpdate, ShoppingListOut

class ShoppingListService:
    def __init__(self, session: AsyncSession):
        self.repository = ShoppingListRepository(session)
        self.recommendation_service = RecommendationService(session)

    async def get_user_lists(self, user_id: int) -> list[ShoppingListOut]:
        lists = await self.repository.get_by_user_id(user_id)
        return [ShoppingListOut.model_validate(lst) for lst in lists]

    async def generate_weekly_list(
        self, 
        user_id: int, 
        week_number: int, 
        product_ids: list[int]
    ) -> ShoppingListOut:
        # Vérifier si une liste existe déjà pour cette semaine
        existing_list = await self.repository.get_by_week_and_user(
            week_number, user_id, datetime.now().year
        )
        if existing_list:
            raise ValueError("List already exists for this week")
        
        # Générer la liste avec le service de recommandations
        shopping_list = await self.recommendation_service.generate_weekly_list(
            user_id, week_number, product_ids
        )
        
        return ShoppingListOut.model_validate(shopping_list)

    async def complete_list(self, list_id: int, user_id: int) -> ShoppingListOut:
        shopping_list = await self.repository.get_by_id_and_user(list_id, user_id)
        if not shopping_list:
            raise ValueError("List not found or access denied")
        
        shopping_list.status = "completed"
        await self.repository.update(list_id, {"status": "completed"})
        
        return ShoppingListOut.model_validate(shopping_list)

    async def get_list_with_items(self, list_id: int, user_id: int) -> ShoppingListOut:
        shopping_list = await self.repository.get_by_id_and_user(list_id, user_id)
        if not shopping_list:
            raise ValueError("List not found or access denied")
        
        return ShoppingListOut.model_validate(shopping_list)