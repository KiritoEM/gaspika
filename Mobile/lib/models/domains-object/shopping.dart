import 'package:gaspika_mobile/constants/enums/enums.dart';

// ========= ShoppingListItem =========
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
      category: json['category'] as String?,
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

  Map<String, dynamic> toJson() {
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
      'unit': quantityUnit != null
          ? _mapQuantityUnitToString(quantityUnit!)
          : null,
    };
  }

  static String _mapQuantityUnitToString(QuantityUnit unit) {
    switch (unit) {
      case QuantityUnit.piece:
        return 'unit';
      case QuantityUnit.kilogram:
        return 'kg';
      case QuantityUnit.liter:
        return 'l';
      case QuantityUnit.gram:
        return 'g';
      case QuantityUnit.milliliter:
        return 'ml';
    }
  }

  @override
  String toString() {
    return 'ShoppingListItem{id: $id, productName: $productName, shoppingListId: $shoppingListId, estimatedQuantity: $estimatedQuantity, price: $price, isPurchased: $isPurchased, notes: $notes, storageTips: $storageTips, categoryId: $categoryId, category: $category, unit: $quantityUnit}';
  }
}

// ========= ShoppingList =========
class ShoppingList {
  final int? id;
  final int weekNumber;
  final String? name;
  final String? status;
  final int totalEstimatedCost;
  final int? userId;
  final bool isCompleted;
  final List<ShoppingListItem>? items;

  ShoppingList({
    this.id,
    required this.weekNumber,
    this.name,
    this.status,
    this.totalEstimatedCost = 0,
    this.userId,
    this.isCompleted = false,
    this.items,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as int?,
      weekNumber: json['week_number'] as int,
      name: json['name'] as String?,
      status: json['status'] as String?,
      totalEstimatedCost: (json['total_estimated_cost'] as int?) ?? 0,
      userId: json['user_id'] as int?,
      isCompleted: json['is_completed'] ?? false,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => ShoppingListItem.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_number': weekNumber,
      'name': name,
      'status': status,
      'total_estimated_cost': totalEstimatedCost,
      'user_id': userId,
      'is_completed': isCompleted,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  // Return the number of items in the shopping list
  int get itemCount => items?.length ?? 0;

  @override
  String toString() {
    return 'ShoppingList{id: $id, weekNumber: $weekNumber, name: $name, status: $status, totalEstimatedCost: $totalEstimatedCost, userId: $userId, isCompleted: $isCompleted, itemCount: $itemCount}';
  }
}
