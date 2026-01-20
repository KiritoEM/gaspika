from typing import TypeVar
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
from app.core.schemas import PageParams, PagedResponseSchema

T = TypeVar("T")

async def paginate(
    session: AsyncSession,
    page_params: PageParams, 
    query, 
    ResponseSchema: type[BaseModel]
) -> PagedResponseSchema[T]:
    """Paginate the query """
    
    offset = (page_params.page - 1) * page_params.limit
    
    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar_one()
    
    paginated_query = query.offset(offset).limit(page_params.limit)
    results = await session.execute(paginated_query)
    items = results.unique().scalars().all()
    
    return PagedResponseSchema(
        total=total,
        page=page_params.page,
        limit=page_params.limit,
        results=[ResponseSchema.model_validate(item) for item in items], 
    )
