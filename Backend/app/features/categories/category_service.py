import json
from typing import List
from app.core.redis_client import get_redis_client
from app.features.categories.category_repository import CategoryRepository
from app.features.categories.category_schemas import BaseCategory, CategoryOutDTO, CreateCategoryDTO

class CategoryServices:
    def __init__(self, category_repo: CategoryRepository):
        self.category_repo = category_repo
        self.redis_client = get_redis_client()
    
    async def get_all_categories(self) -> list[CategoryOutDTO]:
        cache_key = "all-categories"
        
        cached_categories : List = await self.redis_client.lrange(cache_key, 0, -1)
        
        if cached_categories:
            categories =  [json.loads(category) for category in cached_categories]
            
            return [CategoryOutDTO(data=BaseCategory.model_validate(cat)) for cat in categories]
        
        categories = await self.category_repo.get_all()
        
        # add categories to cache
        for category in categories:
            category_dict = {
                "id": category.id,
                "name": category.name,
                "description": category.description,
                "created_at": category.created_at.isoformat() if category.created_at else None,
                "updated_at": category.updated_at.isoformat() if category.updated_at else None
            }
            
            pipeline = self.redis_client.pipeline()
            
            await pipeline.lpush(cache_key, json.dumps(category_dict))
            await pipeline.expire(cache_key, 60 * 60 * 24 * 4) # 4 days
            await pipeline.execute()
        
        
        return [CategoryOutDTO(data=BaseCategory.model_validate(cat)) for cat in categories]
    
    async def create_category(self, payload: CreateCategoryDTO) -> CategoryOutDTO:
        category = await self.category_repo.create(**payload.model_dump())
        return CategoryOutDTO.model_validate(category)