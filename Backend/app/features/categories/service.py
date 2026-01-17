import json
from sqlalchemy.ext.asyncio import AsyncSession
from app.features.categories.repository import CategoryRepository
from app.features.categories.schemas import CategoryBase, CategoryOut
from app.core.redis_client import redis_client

class CategoryService:
    def __init__(self, session: AsyncSession):
        self.repository = CategoryRepository(session)

    async def get_all_categories(self, use_cache: bool = True) -> list[CategoryOut]:
        # Vérifier le cache Redis
        if use_cache:
            cached = redis_client.get("categories:all")
            if cached:
                payloads = json.loads(cached)
                return [CategoryOut.model_validate(p) for p in payloads]

        # Récupérer depuis la base de données
        categories = await self.repository.get_all()
        data = [CategoryOut.model_validate(cat) for cat in categories]
        
        # Mettre en cache
        redis_client.setex(
            "categories:all", 
            300,  # 5 minutes
            json.dumps([d.model_dump() for d in data])
        )
        
        return data

    async def create_category(self, category_data: CategoryBase) -> CategoryOut:
        # Créer la catégorie
        category = await self.repository.create(category_data.model_dump())
        
        # Invalider le cache
        redis_client.delete("categories:all")
        
        return CategoryOut.model_validate(category)