from datetime import datetime
from fastapi import HTTPException
from app.core.enums import ShoppingListItemEnum
from app.features.users.user_repository import UserRepository
from app.features.shopping_items.shopping_items_schemas import CreateShoppingItemDTO, UpdateShoppingItemDTO
from app.features.shopping_items.shopping_items_repository import ShoppingItemsRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository

class ShoppingItemsServices:
    def __init__(
        self,
        shoppingListRepo: ShoppingListRepository, 
        shoppingItemRepo: ShoppingItemsRepository,                 
        userRepo: UserRepository
    ):
        self.shoppingListRepo = shoppingListRepo
        self.shoppingItemRepo = shoppingItemRepo
        self.userRepo = userRepo

    async def add_item_to_list(self, list_id: int, user_id: str, payload: CreateShoppingItemDTO):
        # Verify list exists
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user_id)
        if not shopping_list:
            raise HTTPException(404, "Liste introuvable")
        
        # Check if the item exist already in the current user list
        shopping_items = await self.shoppingItemRepo.search_by_food_name(payload.food_name, user_id)
        
        if shopping_items:
            raise HTTPException(409,detail="Cet aliment existe déja dans votre liste actuelle.")

        # Create shopping item
        item = await self.shoppingItemRepo.create(list_id, user_id, payload)
        
        if not item:
            raise HTTPException(status_code=400, detail="Impossible d'ajouter l'aliment.")
        
        # Update total cost of the list
        total_list_prices = await self.shoppingItemRepo.get_total_price(user_id, list_id)
        await self.shoppingListRepo.replace_total_cost(list_id, total_list_prices)
        
        return item
    
    async def get_all_items(self, list_id: int, user_id: str) -> list[dict]:
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user_id)
        
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
        
        all_items =  await self.shoppingItemRepo.get_all(shopping_list.id)
        
        return all_items
        
    async def get_shopping_item_by_id(self, item_id: int, list_id:int, user_id: str):
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user_id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
        
        shopping_item =  await self.shoppingItemRepo.get_by_id(item_id, user_id, shopping_list.id)
        
        if not shopping_item:
            raise HTTPException(status_code=404, detail="Aliment introuvable dans cette liste.")
        
        return shopping_item
    
    async def get_available_items_count(self, user_id: str, week_number: int):
        shopping_list = await self.shoppingListRepo.get_list_by_week(week_number, user_id, datetime.now().year)
        
        if not shopping_list:
            return 0
        
        return await self.shoppingItemRepo.get_items_count(user_id, shopping_list.id, ShoppingListItemEnum.UNPURCHASED)
            
    
    async def complete_shopping_item(self, item_id: int, list_id:int, user_id: str):
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user_id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")   
        
        shopping_item =  await self.shoppingItemRepo.complete_item(item_id, user_id, shopping_list.id)
        
        if not shopping_item:
            raise HTTPException(status_code=400, detail="Impossible de marquer cet aliment comme acheté.")
        
        return shopping_item
    
    async def update_shopping_item(self, item_id: int, list_id:int, user_id: str, payload: UpdateShoppingItemDTO):
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user_id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
        
        shopping_item =  await self.shoppingItemRepo.update(item_id, user_id, shopping_list.id, payload)
        
        if not shopping_item:
            raise HTTPException(status_code=400, detail="Impossible de mettre a jour cet aliment.")
        
        # update total_cost of the list if the price or unit is updated
        total_list_prices = await self.shoppingItemRepo.get_total_price(user_id, shopping_list.id)
        await self.shoppingListRepo.replace_total_cost(list_id, total_list_prices)
        
        return shopping_item
    
    
    