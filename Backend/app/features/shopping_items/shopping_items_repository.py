from datetime import datetime, timezone
from typing import Optional
from sqlalchemy.orm import joinedload
from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.date import get_week_number
from app.features.shopping_items.shopping_items_schemas import BaseShoppingListItem, CreateShoppingItemDTO, UpdateShoppingItemDTO
from app.core.enums import ShoppingListItemEnum
from app.models import ShoppingList, ShoppingListItem, User


class ShoppingItemsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, list_id: int, user_id: str, item_data: CreateShoppingItemDTO) -> ShoppingListItem:
        shopping_item = ShoppingListItem(
            food_name=item_data.food_name, recommended_quantity=item_data.quantity,
            price=item_data.price, person_number=item_data.person_number,
            notes=item_data.notes, unit=item_data.unit,
            default_shelf_life_day=item_data.default_shelf_life_day,
            food_category_id=item_data.food_category_id, storage_tips=item_data.storage_tips,
            shopping_list_id=list_id, user_id=user_id
        )
        self.db.add(shopping_item)
        await self.db.commit()
        return shopping_item

    async def get_all(self, list_id: int, week_number: int) -> list[BaseShoppingListItem]:
        result = await self.db.execute(
            select(ShoppingListItem).join(ShoppingListItem.shopping_list)
            .where(ShoppingList.id == list_id).order_by(ShoppingListItem.created_at.desc())
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
        )
        current_week_number = get_week_number(datetime.now())
        all_items = result.scalars().all()
        is_available = current_week_number <= week_number
        return [BaseShoppingListItem.model_validate(item).model_copy(update={"is_available": is_available}) for item in all_items]

    async def get_all_by_user_id(self, user_id: str) -> list[BaseShoppingListItem]:
        all_items = await self.db.execute(
            select(ShoppingListItem).join(ShoppingListItem.user)
            .where(User.id == user_id)
            .order_by(ShoppingListItem.food_name, ShoppingListItem.created_at.desc())
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
            .distinct(ShoppingListItem.food_name)
        )
        return [BaseShoppingListItem.model_validate(item).model_copy(update={"is_available": True}) for item in all_items.scalars().all()]

    async def get_by_id(self, item_id: int, user_id: str) -> Optional[BaseShoppingListItem]:
        shopping_item = await self.db.execute(
            select(ShoppingListItem).join(ShoppingListItem.shopping_list)
            .where(and_(ShoppingList.user_id == user_id, ShoppingListItem.id == item_id))
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
        )
        item = shopping_item.scalars().first()
        if not item:
            return None
        current_week_number = get_week_number(datetime.now())
        is_available = current_week_number <= item.shopping_list.week_number
                
        return BaseShoppingListItem.model_validate(item).model_copy(update={"is_available": is_available})

    async def get_items_count(self, user_id: str, list_id: int, status: Optional[ShoppingListItemEnum] = None) -> Optional[int]:
        query = (
            select(func.coalesce(func.count(ShoppingListItem.id), 0))
            .join(ShoppingListItem.shopping_list)
            .where(and_(ShoppingList.user_id == user_id, ShoppingList.id == list_id))
        )
        if status:
            query = query.where(ShoppingListItem.status == status)
        items_count = await self.db.execute(query)
        return items_count.scalar()

    async def get_items_of_list(self, user_id: str, list_id: int, week_number: int, status: Optional[ShoppingListItemEnum] = None) -> list[BaseShoppingListItem]:
        query = (
            select(ShoppingListItem).join(ShoppingListItem.shopping_list)
            .where(and_(ShoppingList.user_id == user_id, ShoppingList.id == list_id))
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
        )
        if status:
            query = query.where(ShoppingListItem.status == status)
        shopping_items = await self.db.execute(query)
        current_week_number = get_week_number(datetime.now())
        is_available = current_week_number <= week_number
        return [BaseShoppingListItem.model_validate(item).model_copy(update={"is_available": is_available}) for item in shopping_items.scalars().all()]

    async def search_by_food_name(self, name: str, user_id: str) -> list[BaseShoppingListItem]:
        query = (
            select(ShoppingListItem).join(ShoppingListItem.shopping_list)
            .where(ShoppingListItem.food_name.ilike(f"%{name}%"))
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
            .distinct(ShoppingListItem.food_name)
        )
        if user_id:
            query = query.where(ShoppingList.user_id == user_id)
        shopping_item = await self.db.execute(query)

        return [BaseShoppingListItem.model_validate(item).model_copy(update={"is_available": True}) for item in shopping_item.scalars().all()]

    async def search_by_food_name_in_list(self, name: str, user_id: str, list_id: int) -> list[BaseShoppingListItem]:
        query = (
            select(ShoppingListItem).join(ShoppingListItem.shopping_list)
            .where(and_(ShoppingList.id == list_id, ShoppingListItem.food_name.ilike(f"%{name}%")))
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
            .distinct(ShoppingListItem.food_name)
        )
        if user_id:
            query = query.where(ShoppingList.user_id == user_id)
        shopping_item = await self.db.execute(query)
    
        return [BaseShoppingListItem.model_validate(item).model_copy(update={"is_available": True}) for item in shopping_item.scalars().all()]

    async def get_total_price(self, user_id: str, list_id: int) -> float:
        total_price = await self.db.execute(
            select(func.coalesce(func.sum(ShoppingListItem.price * ShoppingListItem.recommended_quantity), 0))
            .join(ShoppingListItem.shopping_list)
            .where(and_(ShoppingList.user_id == user_id, ShoppingList.id == list_id))
        )
        return total_price.scalar()

    async def complete_item(self, item_id: int, user_id: str) -> Optional[ShoppingListItem]:
        result = await self.db.execute(
            select(ShoppingListItem).join(ShoppingListItem.shopping_list)
            .where(and_(ShoppingList.user_id == user_id, ShoppingListItem.id == item_id))
        )
        shopping_item = result.scalar_one_or_none()
        if shopping_item:
            shopping_item.status = ShoppingListItemEnum.PURCHASED
            shopping_item.updated_at = datetime.now(timezone.utc)
            await self.db.commit()
            return shopping_item
        return None

    async def update(self, item_id: int, user_id: str, item_data: UpdateShoppingItemDTO) -> Optional[ShoppingListItem]:
        result = await self.db.execute(
            select(ShoppingListItem).join(ShoppingListItem.shopping_list)
            .where(and_(ShoppingList.user_id == user_id, ShoppingListItem.id == item_id))
            .options(joinedload(ShoppingListItem.category), joinedload(ShoppingListItem.image))
        )
        shopping_item = result.scalars().first()
        if shopping_item:
            for field, value in item_data.model_dump(exclude_unset=True).items():
                setattr(shopping_item, field, value)
            shopping_item.updated_at = datetime.now(timezone.utc)
            await self.db.commit()
            await self.db.refresh(shopping_item, ['category', 'image', 'shopping_list', 'user'])
            return shopping_item
        return None

    async def delete(self, item_id: int, user_id: str) -> bool:
        result = await self.db.execute(
            select(ShoppingListItem).join(ShoppingListItem.shopping_list)
            .where(and_(ShoppingList.user_id == user_id, ShoppingListItem.id == item_id))
        )
        shopping_item = result.scalars().first()
        if shopping_item:
            await self.db.delete(shopping_item)
            await self.db.commit()
            return True
        return False