from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import Image

class ImageRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create(
        self,
        image_name: str,
        image_url: str,
        image_size: int,
        provider: str,
        file_id: str,
        shopping_item_id: Optional[str]
    ):
        image = Image(
            filename= image_name,
            path=image_url,
            size=image_size,
            provider=provider,
            file_id=file_id,
            shopping_list_item_id = shopping_item_id
        )
        
        self.db.add(image)
        await self.db.commit()
        await self.db.refresh(image)
        
        return image