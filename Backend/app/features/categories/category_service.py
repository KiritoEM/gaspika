import json
from typing import List
from app.core.redis_client import get_redis_client
from app.features.categories.category_repository import CategoryRepository
from app.features.categories.category_schemas import BaseCategory, CategoryOutDTO, CreateCategoryDTO

class CategoryServices:
    def __init__(self, category_repo: CategoryRepository):
        self.category_repo = category_repo
        self.redis_client = get_redis_client()
        self.all_categories_cache_key = "all-categories"
    
    async def get_all_categories(self):        
        cached_categories : List = await self.redis_client.lrange(self.all_categories_cache_key, 0, -1)
        
        if cached_categories:
            categories =  [json.loads(category) for category in cached_categories]
            
            return categories
        
        categories = await self.category_repo.get_all()
        
        # add categories to cache
        for category in categories:
            category_dict = {
                "id": category.id,
                "name": category.name,
                "description": category.description,
                "ml_category": category.ml_category,
                "created_at": category.created_at.isoformat() if category.created_at else None,
                "updated_at": category.updated_at.isoformat() if category.updated_at else None
            }
            
            pipeline = self.redis_client.pipeline()
            
            await pipeline.lpush(self.all_categories_cache_key, json.dumps(category_dict))
            await pipeline.expire(self.all_categories_cache_key, 60 * 60 * 24 * 4) # 4 days
            await pipeline.execute()
        
        
        return categories
    
    async def create_category(self, payload: CreateCategoryDTO):
        # invalidate cache
        await self.redis_client.delete(self.all_categories_cache_key)
        
        for category_data in payload:
           await self.category_repo.create(**category_data.model_dump())
