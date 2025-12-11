from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models import ShoppingList, ShoppingListItem, FoodProduct, FoodCategory, User
from app.services.recommendations import compute_optimal_quantity

async def generate_weekly_list(db: AsyncSession, user_id: int, week_number: int, product_ids: list[int]) -> ShoppingList:
    sl = ShoppingList(user_id=user_id, week_number=week_number, name=f"Semaine {week_number}", status="draft")
    db.add(sl)
    await db.flush()

    result_user = await db.execute(select(User).where(User.id == user_id))
    user = result_user.scalar_one_or_none()
    household_size = user.household_size if user else 1

    for pid in product_ids:
        result_p = await db.execute(select(FoodProduct).where(FoodProduct.id == pid))
        p = result_p.scalar_one_or_none()
        if not p:
            continue
        qty = compute_optimal_quantity(p.recommended_quan or 1, household_size)

        result_cat = await db.execute(select(FoodCategory).where(FoodCategory.id == p.category_id))
        cat = result_cat.scalar_one_or_none()

        item = ShoppingListItem(
            product_name=p.name,
            shopping_list_id=sl.id,
            estimated_quantity=qty,
            price=0,
            is_purchased=False,
            notes=None,
            storage_tips=p.storage_tips,
            category_id=cat.id if cat else None
        )
        db.add(item)

    await db.flush()
    sl.total_estimated_cost = sum([(item.price or 0) for item in sl.items]) if sl.items else 0
    return sl