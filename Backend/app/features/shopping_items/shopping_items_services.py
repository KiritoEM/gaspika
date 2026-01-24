from datetime import datetime, date, time
import re
from fastapi import HTTPException
from app.features.images_upload.image_upload_repository import ImageRepository
from app.core.storages.interfaces import StorageProvider
from app.features.shopping_lists.shopping_list_repository import ShoppingListRepository
from app.core.enums import ShoppingListItemEnum
from app.features.users.user_repository import UserRepository
from app.features.shopping_items.shopping_items_schemas import CreateShoppingItemDTO, UpdateShoppingItemDTO
from app.features.shopping_items.shopping_items_repository import ShoppingItemsRepository

class ShoppingItemsServices:
    def __init__(
        self,
        shoppingListRepo: ShoppingListRepository,
        shoppingItemRepo: ShoppingItemsRepository,  
        imageRepo : ImageRepository,
        userRepo: UserRepository,
        storageProvider: StorageProvider,
    ):
        self.shoppingListRepo = shoppingListRepo
        self.shoppingItemRepo = shoppingItemRepo
        self.userRepo = userRepo
        self.imageRepo = imageRepo
        self.storageProvider = storageProvider

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
        

        # Upload image to cloud
        food_name_clean = re.sub(r'[^a-zA-Z0-9]', '_', payload.food_name.lower())[:50]
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        image_name = f"{food_name_clean}_{timestamp}.{payload.image.filename.split('.')[-1]}"
        image_metadata = await self.storageProvider.upload(payload.image, image_name)
        
        if (not image_metadata.success):
            raise HTTPException(502, image_metadata.error)
        
        # Add metadata of image to database
        created_image = await self.imageRepo.create(
            image_name,
            image_metadata.url,
            payload.image.size,
            image_metadata.provider,
            image_metadata.file_id,
            item.id
        )
        
        if not created_image:
            raise HTTPException(status_code=400, detail="Impossible de télécharger l'image de l'aliment.")

        # Update total cost of the list
        total_list_prices = await self.shoppingItemRepo.get_total_price(user_id, list_id)
        await self.shoppingListRepo.replace_total_cost(list_id, total_list_prices)
        
        item.image = created_image
        
        return item
    
    async def get_all_items(self, list_id: int, user_id: str) -> list[dict]:
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user_id)
        
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
                
        return await self.shoppingItemRepo.get_all(shopping_list.id)
        
    async def get_shopping_item_by_id(self, item_id: int, list_id:int, user_id: str):
        shopping_list = await self.shoppingListRepo.get_by_id(list_id, user_id)
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
        
        shopping_item =  await self.shoppingItemRepo.get_by_id(item_id, user_id, shopping_list.id)
        
        if not shopping_item:
            raise HTTPException(status_code=404, detail="Aliment introuvable dans cette liste.")
               
        return shopping_item
    
    async def get_available_items_count(self, user_id: str,week_number: int):
        shopping_list = await self.shoppingListRepo.get_list_by_week(week_number, user_id, datetime.now().year)
        
        if not shopping_list:
            return 0
        
        return await self.shoppingItemRepo.get_items_count(user_id, shopping_list.id, ShoppingListItemEnum.UNPURCHASED)
    
    async def get_available_items(self, user_id: str,week_number: int):
        shopping_list = await self.shoppingListRepo.get_list_by_week(week_number, user_id, datetime.now().year)
        
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Pas de liste disponible pour la semaine.")
        
        return await self.shoppingItemRepo.get_items_of_list(user_id, shopping_list.id, ShoppingListItemEnum.UNPURCHASED)

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
    
    
    