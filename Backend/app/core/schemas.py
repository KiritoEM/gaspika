from typing import Generic, List, TypeVar
from pydantic import BaseModel, conint
from pydantic.generics import GenericModel

class PageParams(BaseModel):
    page: conint(ge=1) = 1 # type: ignore
    limit: conint(ge=1, le=100) = 10 # type: ignore

T = TypeVar("T")

class PagedResponseSchema(GenericModel, Generic[T]):
    total: int
    page: int
    limit: int
    results: List[T]
