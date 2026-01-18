from fastapi import HTTPException
from app.features.shopping_list.shopping_list_schemas import GetAllListsFilterParams
from app.core.schemas import PageParams
from app.features.users.user_repository import UserRepository
from app.features.shopping_list.shopping_list_repository import ShoppingListRepository

class ShoppingListServices:
    def __init__(self, shoppingListRepo: ShoppingListRepository, userRepo: UserRepository):
        self.shoppingListRepo = shoppingListRepo
        self.userRepo = userRepo
        
    async def get_all_lists(self, user_id: str, query: GetAllListsFilterParams):
        user = await self.userRepo.get_user_by_id(user_id)
        
        if (not user):
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        return await self.shoppingListRepo.get_all(
            user_id, 
            query.model_dump()["page"], 
            query.model_dump()["limit"], 
            query.model_dump()["status"],
            
        )