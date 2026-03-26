from pydantic import BaseModel

# Update device schema
class UpdateDeviceDTO(BaseModel):
    fcm_token: str 
    new_fcm_token: str
    
# Update Device response schema
class UpdateDeviceOutDTO(BaseModel):
    message: str