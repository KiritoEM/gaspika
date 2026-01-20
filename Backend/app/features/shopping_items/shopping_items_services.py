from fastapi import HTTPException
from app.features.users.user_repository import UserRepository
from app.features.shopping_items.shopping_items_schemas import CreateShoppingItemDTO, UpdateShoppingItemDTO
from app.features.foods.food_repository import FoodRepository
from app.features.shopping_items.shopping_items_repository import ShoppingItemsRepository
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository

class ShoppingItemsServices:
    def __init__(self, shoppingListRepo: ShoppingListRepository, 
                 foodRepo: FoodRepository,
                 shoppingItemRepo: ShoppingItemsRepository,
                 
                 userRepo: UserRepository
                 ):
        self.shoppingListRepo = shoppingListRepo
        self.foodRepo = foodRepo
        self.shoppingItemRepo = shoppingItemRepo
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
        item = await self.shoppingItemRepo.create(
            list_id,
            food_id, 
            payload.price,
            payload.person_number,
            payload.quantity,
            payload.unit,
        )
        
        # Update total cost of the list
        await self.shoppingListRepo.update_total_cost(list_id, payload.price * payload.quantity)
        
        return item
    
    async def get_all_items(self, list_id: int, user_id: str) -> list[dict]:
        user = await self.userRepo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user.id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
        
        all_items =  await self.shoppingItemRepo.get_all_items(user.id, shopping_list.id)
        
        # Format response to include food table ref
        return [
        {
            "id": item.id,
            "recommanded_quantity": item.recommanded_quantity,
            "price": item.price,
            "total": item.price * item.recommanded_quantity,
            "person_number": item.person_number,
            "unit": item.unit,
            "notes": item.notes,
            "shopping_list_id": item.shopping_list_id,
            "food": item.food,
            "status": item.status,
            "created_at": item.created_at,
            "updated_at": item.updated_at
        }
        for item in all_items
    ]
        
    async def get_shopping_item_by_id(self, item_id: int, list_id:int, user_id: str):
        user = await self.userRepo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user.id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")   
        
        shopping_item =  await self.shoppingItemRepo.get_by_id(item_id, user.id, shopping_list.id)
        
        if not shopping_item:
            raise HTTPException(status_code=404, detail="Aliment introuvable dans cette liste.")
        
        return shopping_item
    
    async def complete_shopping_item(self, item_id: int, list_id:int, user_id: str):
        user = await self.userRepo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user.id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")   
        
        shopping_item =  await self.shoppingItemRepo.complete_item(item_id, user.id, shopping_list.id)
        
        if not shopping_item:
            raise HTTPException(status_code=400, detail="Impossible de marquer cet aliment comme acheté.")
        
        return shopping_item
    
    async def update_shopping_item(self, item_id: int, list_id:int, user_id: str, payload: UpdateShoppingItemDTO):
        user = await self.userRepo.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user.id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")   
        
        shopping_item =  await self.shoppingItemRepo.update(item_id, user.id, shopping_list.id, **payload.model_dump())
        
        # change total_cost of the list if the price or unit is updated
        # if payload.price or payload.unit:
        #     await self.shoppingListRepo.update_total_cost()
            
                
        if not shopping_item:
            raise HTTPException(status_code=400, detail="Impossible de marquer cet aliment comme acheté.")
        
        return shopping_item
    
    
    