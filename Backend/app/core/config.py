from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    app_env: str = Field(default="dev", alias="APP_ENV")
    jwt_secret: str = Field(default="change_me", alias="JWT_SECRET")
    database_url: str = Field(alias="DATABASE_URL")
    redis_url: str = Field(alias="REDIS_URL")
    access_token_expire_minutes: int = Field(default=60, alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    imgbb_api_key : str = Field(alias="IMGBB_API_KEY")
    groq_api_key: str = Field(alias="GROQ_API_KEY")

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()