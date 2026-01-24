from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

#Create SQLAlchemy engine
engine = create_async_engine(settings.database_url, future=True)

#Create SessionLocal class
AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession, 
    autoflush=False,
    expire_on_commit=False,
    autocommit=False
)
#Base class for model
Base = declarative_base()

async def db_session():
    async with AsyncSessionLocal() as session:
        yield session
        await session.commit()
