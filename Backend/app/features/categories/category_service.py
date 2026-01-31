from app.features.categories.category_repository import CategoryRepository
from app.features.categories.category_schemas import CategoryOutDTO, CreateCategoryDTO

class CategoryServices:
    def __init__(self, category_repo: CategoryRepository):
        self.category_repo = category_repo
    
    async def get_all_categories(self) -> list[CategoryOutDTO]:
        categories = await self.category_repo.get_all()
        return [CategoryOutDTO.model_validate(cat) for cat in categories]
    
    async def create_category(self, payload: CreateCategoryDTO) -> CategoryOutDTO:
        category = await self.category_repo.create(**payload.model_dump())
        return CategoryOutDTO.model_validate(category)