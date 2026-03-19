from datetime import datetime
from typing import Optional
from fastapi import HTTPException
from app.models import ShoppingList
from app.features.shopping_lists.shopping_list_schemas import GetAllListsFilterParams, UpdateShoppingListDTO
from app.features.users.user_repository import UserRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository

class ShoppingListServices:
    def __init__(self, shoppingListRepo: ShoppingListRepository, userRepo: UserRepository):
        self.shoppingListRepo = shoppingListRepo
        self.userRepo = userRepo
        
    async def get_all_lists(self, user_id: str, query: GetAllListsFilterParams):  
        return await self.shoppingListRepo.get_all(
            user_id, 
            query.page, 
            query.limit, 
            query.status,
            query.dateInterval,
        )
        
    async def generate_list(self, week_number: int, user_id: str, name: Optional[str] = None):
        existing_list = await self.shoppingListRepo.get_list_by_week(week_number=week_number, year=datetime.now().year, user_id=user_id)
        
        if existing_list:
            raise HTTPException(409, "Une liste existe deja pour cette semaine")
        
        final_name = name if name else f"Courses semaine {week_number}"
        
        return await self.shoppingListRepo.create(week_number, user_id, final_name)
    
    
    async def update_list(self, user_id: str, shopping_lists_id: int, update_data: UpdateShoppingListDTO):
        """Update shopping list"""
        return  await self.shoppingListRepo.update_list(shopping_lists_id, user_id, update_data)
        
    async def delete_list(self, user_id: str, shopping_lists_id: int):
        """Delete shopping list"""
        return await self.shoppingListRepo.delete_list(shopping_lists_id, user_id)
        
