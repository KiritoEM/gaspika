from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

from app.core.config import settings

#Create SQLAlchemy engine
engine = create_engine(settings.database_url, echo=True)

#Create SessionLocal class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

#Base class for model
Base = declarative_base()

def db_session():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()