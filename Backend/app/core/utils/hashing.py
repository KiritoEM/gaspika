from passlib.context import CryptContext

crypto_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
ALGORITHM = "HS256"

def hash_string(p: str) -> str:
    return crypto_context.hash(p)

def verify_hash(p: str, hashed: str) -> str:
    return crypto_context.verify(p, hashed)