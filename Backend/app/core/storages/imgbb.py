from typing import BinaryIO, Optional
from app.core.constants import IMGBB_BASE_URL
from app.core.storages.schemas import UploadResult
from app.core.storages.interfaces import StorageProvider
from app.core.config import settings
import httpx
import base64

class ImgBBProvider(StorageProvider):
    def __init__(self):
       self.api_key = settings.imgbb_api_key
       self.base_url = IMGBB_BASE_URL
    
    async def upload(
        self,
        file: BinaryIO,
        filename: str,
    ) -> UploadResult :
        image_bytes = await file.read()
        image_base64 = base64.b64encode(image_bytes).decode('utf-8')
        
        form_data  = {
            "key" : self.api_key,
            "image": (None, image_base64),
            "name": filename,
        } 
        
        async with httpx.AsyncClient(
             timeout=httpx.Timeout(60.0, read=30.0)
        ) as client:
            response = await client.post(self.base_url, data=form_data )
            
            result = response.json()
            if result.get("status") == 200:
                data_imgbb = result["data"]
                return UploadResult(
                    success=True,
                    url=data_imgbb["url"],
                    file_id=data_imgbb["id"],
                    provider="ImgBB"
            )

            return {
                "success": False,
                "error": "Impossible de télécharger l'aliment via le Provider ImgBB."
            }
            
    async def delete(self, file_id:str):
        pass
    
    async def get_url(self, file_id:str):
        pass