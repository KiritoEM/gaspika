import 'package:gaspika_mobile/constants/enums/enums.dart';

class ShoppingListItem {
  final int? id;
  final String productName;
  final int? shoppingListId;
  final int estimatedQuantity;
  final int price;
  final bool isPurchased;
  final String? notes;
  final String? storageTips;
  final int? categoryId;
  final String? category;
  final QuantityUnit? quantityUnit;

  ShoppingListItem({
    this.id,
    required this.productName,
    this.shoppingListId,
    required this.estimatedQuantity,
    required this.price,
    required this.isPurchased,
    this.notes,
    this.storageTips,
    this.categoryId,
    this.category,
    this.quantityUnit,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] as int?,
      productName: json['product_name'] ?? '',
      shoppingListId: json['shopping_list_id'] as int?,
      estimatedQuantity: (json['estimated_quantity'] as int?) ?? 1,
      price: (json['price'] as int?) ?? 0,
      isPurchased: json['is_purchased'] ?? false,
      notes: json['notes'] as String?,
      storageTips: json['storage_tips'] as String?,
      categoryId: json['category_id'] as int?,
      quantityUnit: json['unit'] != null
          ? _mapIntoQuantityUnit(json['unit'])
          : null,
    );
  }

  static QuantityUnit _mapIntoQuantityUnit(String? quantityUnit) {
    switch (quantityUnit) {
      case 'unit':
        return QuantityUnit.piece;
      case 'kg':
        return QuantityUnit.kilogram;
      case 'l':
        return QuantityUnit.liter;
      case 'g':
        return QuantityUnit.gram;
      case 'ml':
        return QuantityUnit.milliliter;
      default:
        return QuantityUnit.piece;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_name': productName,
      'shopping_list_id': shoppingListId,
      'estimated_quantity': estimatedQuantity,
      'price': price,
      'is_purchased': isPurchased,
      'notes': notes,
      'storage_tips': storageTips,
      'category_id': categoryId,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'ShoppingListItem{id: $id, productName: $productName, shoppingListId: $shoppingListId, estimatedQuantity: $estimatedQuantity, price: $price, isPurchased: $isPurchased, notes: $notes, storageTips: $storageTips, categoryId: $categoryId, category: $category}';
  }
}
