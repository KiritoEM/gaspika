import enum

class ShoppingListStatusEnum(enum.Enum):
    COMPLETED = "COMPLETED"
    UNFINISHED = "UNFINISHED"
    ONGOING = "ONGOING"
    
class UnitEnum(enum.Enum):
    UNIT = "unit"
    KG = "kg"
    ML = "ml"