from datetime import datetime, timedelta
from jose import jwt
from app.core.config import settings

def create_JWT(payload: dict, expires_minutes: int | None = None) -> str:
    expiresIn = datetime.utcnow() + timedelta(minutes=expires_minutes or settings.access_token_expire_minutes)
    payload['exp'] = expiresIn
    
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")