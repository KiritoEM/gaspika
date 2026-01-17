import json
from sqlalchemy.ext.asyncio import AsyncSession
from app.features.products.repository import ProductRepository
from app.features.products.schemas import ProductBase, ProductOut
from app.core.redis_client import redis_client

class ProductService:
    def __init__(self, session: AsyncSession):
        self.repository = ProductRepository(session)

    async def get_all_products(self, use_cache: bool = True) -> list[ProductOut]:
        if use_cache:
            cached = redis_client.get("products:all")
            if cached:
                payloads = json.loads(cached)
                return [ProductOut.model_validate(p) for p in payloads]

        products = await self.repository.get_all()
        data = []
        for product in products:
            product_out = ProductOut.model_validate(product)
            # Ajouter le nom de la catégorie si la relation est chargée
            if product.category:
                product_out.category_name = product.category.name
            data.append(product_out)
        
        # Mettre en cache
        redis_client.setex(
            "products:all", 
            300,  # 5 minutes
            json.dumps([d.model_dump() for d in data])
        )
        
        return data

    async def create_product(self, product_data: ProductBase) -> ProductOut:
        product = await self.repository.create(product_data.model_dump())
        
        # Invalider le cache
        redis_client.delete("products:all")
        
        product_out = ProductOut.model_validate(product)
        if product.category:
            product_out.category_name = product.category.name
            
        return product_out

    async def get_products_by_category(self, category_id: int) -> list[ProductOut]:
        cache_key = f"products:category:{category_id}"
        cached = redis_client.get(cache_key)
        if cached:
            payloads = json.loads(cached)
            return [ProductOut.model_validate(p) for p in payloads]

        products = await self.repository.get_by_category(category_id)
        data = [ProductOut.model_validate(p) for p in products]
        
        redis_client.setex(cache_key, 300, json.dumps([d.model_dump() for d in data]))
        
        return data