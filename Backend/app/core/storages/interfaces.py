from abc import ABC, abstractmethod
from typing import BinaryIO, Optional
from app.core.storages.schemas import UploadResult

class StorageProvider(ABC):    
    @abstractmethod
    async def upload(
        self,
        file: BinaryIO,
        filename: str
    ) -> UploadResult:
        """Upload a file"""
        pass
    
    @abstractmethod
    async def delete(self, params: dict) -> bool:
        """Delete a file"""
        pass
    
    @abstractmethod
    async def get_url(self, file_id: str) -> str:
        """Get URL of a specific file"""
        pass