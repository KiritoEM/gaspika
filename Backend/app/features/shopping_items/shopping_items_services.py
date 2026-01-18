from fastapi import HTTPException
from app.features.users.user_repository import UserRepository
from app.models import ShoppingListItem
from app.features.shopping_items.shopping_items_schemas import CreateShoppingItemDTO
from app.features.foods.food_repository import FoodRepository
from app.features.shopping_items.shopping_items_repository import ShoppingItemsRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository

class ShoppingItemsServices:
    def __init__(self, shoppingListRepo: ShoppingListRepository, 
                 foodRepo: FoodRepository,
                 itemRepo: ShoppingItemsRepository,
                 userRepo: UserRepository
                 ):
        self.shoppingListRepo = shoppingListRepo
        self.foodRepo = foodRepo
        self.itemRepo = itemRepo
        self.userRepo = userRepo

    async def add_item_to_list(self, list_id: int, user_id: str, payload: CreateShoppingItemDTO):
        # Verify list exists
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user_id)
        if not shopping_list:
            raise HTTPException(404, "Liste introuvable")

        food_id: int
        
        # If food_id is provided, verify it exists
        if payload.food_id:
            food = await self.foodRepo.get_by_id(payload.food_id)
            if not food:
                raise HTTPException(404, "Aliment introuvable dans la base")
            food_id = payload.food_id
        else:
            # Find food by name or create it
            food = await self.foodRepo.get_by_name(payload.name)
            if not food:
                food = await self.foodRepo.create(
                    payload.name, 
                    payload.default_shelf_life_day, 
                    payload.category_id
                )
            food_id = food.id

        # Create shopping item
        item = await self.itemRepo.create(
            list_id,
            food_id, 
            payload.price,
            payload.person_number,
            payload.quantity,
            payload.unit,
        )
        
        # Update total cost of the list
        await self.shoppingListRepo.update_total_cost(list_id,    payload.price * payload.quantity)
        
        return item
    
    async def get_all_items(self, list_id: int, user_id: int) -> list[ShoppingListItem]:
        user = await self.userRepo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user.id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
        
        return await self.itemRepo.get_all_items(user.id, shopping_list.id)