from datetime import datetime, timedelta
from jose import jwt, JWTError, ExpiredSignatureError
from app.core.config import settings

def create_JWT(payload: dict, expires_minutes: int | None = None) -> str:
    expires_in = datetime.utcnow() + timedelta(minutes=expires_minutes or settings.access_token_expire_minutes)
    payload['exp'] = int(expires_in.timestamp())
    
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")

def decode_JWT(token: str) -> dict | None: 
    try:
        decoded_token = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
        return decoded_token
    except ExpiredSignatureError:
        return None  
    except JWTError:
        return None