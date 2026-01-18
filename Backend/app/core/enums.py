import enum

class ShoppingListStatusEnum(enum.Enum):
    COMPLETED = "COMPLETED"
    UNFINISHED = "UNFINISHED"
    ONGOING = "ONGOING"
    
class ShoppingListIntervalDateEnum(enum.Enum):
    LAST_YEAR="LAST_YEAR"
    CURRENT_YEAR="CURRENT_YEAR"
    CURRENT_MONTH="CURRENT_MONTH"
    LAST_5_MONTH="LAST_5_MONTH"

    
class UnitEnum(enum.Enum):
    UNIT = "unit"
    KG = "kg"
    ML = "ml"