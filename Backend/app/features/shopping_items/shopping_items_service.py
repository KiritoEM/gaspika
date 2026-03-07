from datetime import datetime, date, time
import json
import re
from typing import List
from fastapi import HTTPException
from app.core.redis_client import get_redis_client
from app.features.devices.device_repository import DeviceRepository
from app.core.notification_push import send_android_notification
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
        shopping_list_repo: ShoppingListRepository,
        shopping_item_repo: ShoppingItemsRepository,
        image_repo : ImageRepository,
        user_repo: UserRepository,
        storage_provider: StorageProvider,
        device_repo: DeviceRepository    
    ):
        self.shopping_list_repo = shopping_list_repo
        self.shopping_item_repo = shopping_item_repo
        self.user_repo = user_repo
        self.imageRepo = image_repo
        self.storage_provider = storage_provider
        self.device_repo = device_repo
        self.redis_client = get_redis_client()
        
        
    async def search_food_by_name(self,  user_id: str, query: str):
        # get chached items if already cached
        cache_key = f"shopping-items:{user_id}"
        
        cached_shopping_items : List = await self.redis_client.lrange(cache_key, 0, 19)
                
        if cached_shopping_items:
            searched_items = [json.loads(item) for item in cached_shopping_items]
            return [i for i in searched_items if query.lower() in i["food_name"].lower()]
                
        # cache shopping_items
        all_user_shopping_items = await self.shopping_item_repo.get_all_by_user_id(user_id)
                
        if all_user_shopping_items:
            pipeline = await self.redis_client.pipeline()
            
            for item in all_user_shopping_items:
                item_dict = {
                    "id": item.id,
                    "food_name": item.food_name,
                    "price": float(item.price) if item.price else None,
                    "recommended_quantity": item.recommended_quantity,
                    "unit": item.unit.value if item.unit else None,
                    "notes": item.notes,
                    "person_number": item.person_number,
                    "default_shelf_life_day": item.default_shelf_life_day,
                    "storage_tips": item.storage_tips,
                    "food_category_id": item.food_category_id,
                    "shopping_list_id": item.shopping_list_id,
                    "status": item.status.value if item.status else None,
                    "user_id": str(item.user_id),
                    "created_at": item.created_at.isoformat() if item.created_at else None,
                    "updated_at": item.updated_at.isoformat() if item.updated_at else None,
                    "category": {
                        "id": item.category.id,
                        "name": item.category.name,
                    } if item.category else None,
                    "image": {
                        "id": str(item.image.id),
                        "path": item.image.path,
                        "size": item.image.size,
                        "filename": item.image.filename,
                        "file_id": item.image.file_id, 
                        "provider": item.image.provider,
                        "updated_at":  item.image.updated_at.isoformat() if item.image.updated_at else None,
                    } if item.image else None,
                }
               
                await pipeline.lpush(cache_key, json.dumps(item_dict))
                        
            await pipeline.ltrim(cache_key, 0, 19)
            await pipeline.expire(cache_key, 60 * 60 * 24 * 4) # 4 days
            await pipeline.execute()
        
        return await self.shopping_item_repo.search_by_food_name(query, user_id)
    

    async def add_item_to_list(self, list_id: int, user_id: str, payload: CreateShoppingItemDTO):        
        shopping_list = await self.shopping_list_repo.get_by_id(list_id, user_id)
        
        if not shopping_list:
            raise HTTPException(404, "Liste introuvable")
        
        shopping_items = await self.shopping_item_repo.search_by_food_name_in_list(payload.food_name, user_id, shopping_list.id)
        
        if shopping_items:
            raise HTTPException(409,detail="Cet aliment existe déja dans votre liste actuelle.")
        
        item = await self.shopping_item_repo.create(list_id, user_id, payload)
        
        if not item:
            raise HTTPException(status_code=400, detail="Impossible d'ajouter l'aliment.")
        
        if payload.image:
            food_name_clean = re.sub(r'[^a-zA-Z0-9]', '_', payload.food_name.lower())[:50]
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            image_name = f"{food_name_clean}_{timestamp}.{payload.image.filename.split('.')[-1]}"
            image_metadata = await self.storage_provider.upload(payload.image, image_name)
            
            if (not image_metadata.success):
                raise HTTPException(502, image_metadata.error)
            
            created_image = await self.imageRepo.create(
                image_name,
                image_metadata.url,
                payload.image.size,
                image_metadata.provider,
                image_metadata.file_id,
                image_metadata.delete_url,
                item.id
            )
        
            if not created_image:
                raise HTTPException(status_code=400, detail="Impossible de télécharger l'image de l'aliment.")
            
            item.image = created_image
                        
        await self.shopping_list_repo.rollback_list_to_unfinished(list_id, user_id)

        total_list_prices = await self.shopping_item_repo.get_total_price(user_id, list_id)
        await self.shopping_list_repo.replace_total_cost(list_id, total_list_prices)
        
        device = await self.device_repo.get_by_user_id(user_id)
        
        if not device:
            raise HTTPException(status_code=404, detail="Impossible de trouver le device")
        
        # invalidate cache
        await self.redis_client.delete(f"shopping-items:{user_id}")
        
        await send_android_notification(
            fcm_token=device.fcm_token,
            title="Aliment ajouté !",
            body=f"« {payload.food_name} » a été ajouté à votre liste de courses.",
            data={"route": f"/shopping-list/{str(list_id)}?name={shopping_list.name}&week={shopping_list.week_number}"}
        )
                    
    async def get_all_items(self, list_id: int, user_id: str) -> list[dict]:
        shopping_list = await self.shopping_list_repo.get_by_id(list_id, user_id)
        
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Liste introuvable.")
                
        return await self.shopping_item_repo.get_all(shopping_list.id)
        
    async def get_shopping_item_by_id(self, item_id: int, user_id: str):
        return await self.shopping_item_repo.get_by_id(item_id, user_id)
                   
    async def get_available_items_count(self, user_id: str,week_number: int):
        shopping_list = await self.shopping_list_repo.get_list_by_week(week_number, user_id, datetime.now().year)
        
        if not shopping_list:
            return 0
        
        return await self.shopping_item_repo.get_items_count(user_id, shopping_list.id, ShoppingListItemEnum.UNPURCHASED)
    
    async def get_available_items(self, user_id: str,week_number: int):
        shopping_list = await self.shopping_list_repo.get_list_by_week(week_number, user_id, datetime.now().year)
        
        if not shopping_list:
            raise HTTPException(status_code=404, detail="Pas de liste disponible pour la semaine.")
        
        return await self.shopping_item_repo.get_items_of_list(user_id, shopping_list.id, ShoppingListItemEnum.UNPURCHASED)

    async def complete_shopping_item(self, item_id: int, user_id: str):   
        shopping_item = await self.shopping_item_repo.complete_item(item_id, user_id)
        
        if not shopping_item:
            raise HTTPException(status_code=400, detail="Impossible de marquer cet aliment comme acheté.")
        
        unpurchased_items_count = await self.shopping_item_repo.get_items_count(user_id, shopping_item.shopping_list_id, ShoppingListItemEnum.UNPURCHASED)
        
        if unpurchased_items_count == 0:
            await self.shopping_list_repo.complete_list(shopping_item.shopping_list_id, user_id)
            
        return shopping_item
    
    async def update_shopping_item(self, item_id: int, user_id: str, payload: UpdateShoppingItemDTO): 
        shopping_item = await self.shopping_item_repo.update(item_id, user_id, payload)
        
        if not shopping_item:
            raise HTTPException(status_code=400, detail="Impossible de mettre a jour cet aliment.")
        
        total_list_prices = await self.shopping_item_repo.get_total_price(user_id, shopping_item.shopping_list_id)
        await self.shopping_list_repo.replace_total_cost(shopping_item.shopping_list_id, total_list_prices)
                
        return shopping_item
    
    
    async def delete_shopping_item(self, item_id: int, user_id: str):   
        shopping_item = await self.shopping_item_repo.get_by_id(item_id, user_id)
        
        if not shopping_item:
            raise HTTPException(status_code=404, detail="Aliment introuvable.")
        
        deleted_image = await self.storage_provider.delete({"delete_url" : shopping_item.image.delete_url})
        
        if not deleted_image:
            raise HTTPException(status_code=502, detail="Impossible de supprimer l'image depuis le cloud.")
        
        return await self.shopping_item_repo.delete(item_id, user_id)