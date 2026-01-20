from typing import Optional
from fastapi import HTTPException
from app.models import ShoppingList
from app.features.shopping_lists.shopping_list_schemas import GetAllListsFilterParams
from app.features.users.user_repository import UserRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository

class ShoppingListServices:
    def __init__(self, shoppingListRepo: ShoppingListRepository, userRepo: UserRepository):
        self.shoppingListRepo = shoppingListRepo
        self.userRepo = userRepo
        
    async def get_all_lists(self, user_id: str, query: GetAllListsFilterParams):
        user = await self.userRepo.get_user_by_id(user_id)
        
        if (not user):
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        return await self.shoppingListRepo.get_all(
            user.id, 
            query.page, 
            query.limit, 
            query.status,
            query.dateInterval,
        )
        
    async def generate_list(self, week_number: int, user_id: str, name: Optional[str] = None):
        existing_list = await self.shoppingListRepo.get_list_by_week(week_number, user_id)
        
        if existing_list:
            raise HTTPException(409, "Une liste existe deja pour cette semaine")
        
        final_name = name if name else f"Courses semaine {week_number}"
        
        return await self.shoppingListRepo.create(week_number, user_id, final_name)
    
    async def update_list(self, user_id: str, shopping_lists_id: int, 
                     update_data: dict) -> ShoppingList:
        """Update shopping list"""
        user = await self.userRepo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        shopping_lists = await self.shoppingListRepo.update_list(
            shopping_lists_id, user_id, 
            update_data.get("name"),
            update_data.get("week_number")
        )
        
        if not shopping_lists:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
        
        return shopping_lists

    async def delete_list(self, user_id: str, shopping_lists_id: int) -> dict:
        """Delete shopping list"""
        user = await self.userRepo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        deleted = await self.shoppingListRepo.delete_list(shopping_lists_id, user_id)
        if not deleted:
            raise HTTPException(status_code=400, detail="Impossible de supprimer la liste de courses.")
        
        return {"message": "Liste supprimée avec succès"}
