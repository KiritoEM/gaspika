from pydantic import BaseModel

class CategoryBase(BaseModel):
    name: str
    description: str | None = None
    icon_url: str | None = None

class CategoryOut(CategoryBase):
    id: int
    is_active: bool = True

    class Config:
        from_attributes = True