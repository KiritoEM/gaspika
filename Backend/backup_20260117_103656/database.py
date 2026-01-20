from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from app.config import settings

# Moteur async
engine = create_async_engine(settings.database_url, echo=True)

# Session async
AsyncSessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False
)

Base = declarative_base()

# Dépendance FastAPI pour obtenir une session
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session