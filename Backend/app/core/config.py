from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    app_env: str = Field(default="dev", alias="APP_ENV")
    jwt_secret: str = Field(default="change_me", alias="JWT_SECRET")
    database_url: str = Field(alias="DATABASE_URL")
    access_token_expire_minutes: int = Field(default=60, alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    imgbb_api_key : str = Field(alias="IMGBB_API_KEY")
    groq_api_key: str = Field(alias="GROQ_API_KEY")
    firebase_project_id: str = Field(alias="FIREBASE_PROJECT_ID")
    firebase_creds_path: str = Field(alias="FIREBASE_CREDS_PATH")
    redis_host: str = Field(alias="REDIS_HOST")
    redis_password: str = Field(alias="REDIS_PASSWORD")
    redis_port: int = Field(default= 6379, alias="REDIS_PORT")

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()