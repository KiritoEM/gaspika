from app.features.devices.device_schemas import UpdateDeviceDTO
from app.features.devices.device_repository import DeviceRepository

class DeviceServices:
    def __init__(self, device_repo: DeviceRepository):
        self.device_repo = device_repo
        
    async def update_device(self, user_id: str, data: UpdateDeviceDTO):
        # delete fcm token
        await self.device_repo.delete_by_fcm_token(data.fcm_token)
        
        # generate new fcm_token
        await self.device_repo.create(data.new_fcm_token, user_id)