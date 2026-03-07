import redis.asyncio as redis
from app.core.config import settings    

def get_redis_client() -> redis.Redis :
    redis_connection_pool = redis.ConnectionPool(host=settings.redis_host, port=settings.redis_port, db=0, decode_responses=True)
    
    return redis.Redis(connection_pool=redis_connection_pool)