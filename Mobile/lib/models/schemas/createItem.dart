// models/schemas/createItem.dart

import 'package:gaspika_mobile/constants/enums/enums.dart';

class CreateShoppingItemSchema {
  String productName = '';
  double estimatedQuantity = 0.0;
  QuantityUnit unit = QuantityUnit.piece;
  double price = 0.0;
  bool isPurchased = false;
  String notes = '';
  String storageTips = '';
  int categoryId = 0;

  CreateShoppingItemSchema({
    this.productName = '',
    this.estimatedQuantity = 0.0,
    this.unit = QuantityUnit.piece,
    this.price = 0.0,
    this.isPurchased = false,
    this.notes = '',
    this.storageTips = '',
    this.categoryId = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_name": productName.trim(),
      "estimated_quantity": estimatedQuantity,
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
      case QuantityUnit.piece:
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
