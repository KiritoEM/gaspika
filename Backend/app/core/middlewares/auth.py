from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from app.core.security import verify_token  # Si vous avez cette fonction

class AuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        # Logique d'authentification
        # ...
        response = await call_next(request)
        return response