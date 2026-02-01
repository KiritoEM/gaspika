// models/schemas/createItem.dart

import 'package:gaspika_mobile/constants/enums/enums.dart';

class CreateShoppingItemSchema {
  String foodName = '';
  double recommendedQuantity = 0.0;
  QuantityUnit unit = QuantityUnit.unit;
  double price = 0.0;
  bool isPurchased = false;
  String notes = '';
  String storageTips = '';
  int categoryId = 0;

  CreateShoppingItemSchema({
    this.foodName = '',
    this.recommendedQuantity = 0.0,
    this.unit = QuantityUnit.unit,
    this.price = 0.0,
    this.isPurchased = false,
    this.notes = '',
    this.storageTips = '',
    this.categoryId = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_name": foodName.trim(),
      "estimated_quantity": recommendedQuantity,
      "unit": _mapToBackendUnit(unit),
      "price": price,
      "is_purchased": isPurchased,
      "notes": notes.trim().isEmpty ? null : notes.trim(),
      "storage_tips": storageTips.trim().isEmpty ? null : storageTips.trim(),
      "category_id": categoryId == 0 ? null : categoryId,
    };
  }

  String _mapToBackendUnit(QuantityUnit unit) {
    switch (unit) {
      case QuantityUnit.unit:
        return "unit";
      case QuantityUnit.kilogram:
        return "kg";
      case QuantityUnit.gram:
        return "g";
      case QuantityUnit.liter:
        return "l";
      case QuantityUnit.milliliter:
        return "ml";
    }
  }
}
