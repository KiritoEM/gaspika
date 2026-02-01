import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/domains-object/image.dart';

// ========= ShoppingListItem =========
class ShoppingListItem {
  final String? id;
  final String foodName;
  final int? shoppingListId;
  final double recommendedQuantity;
  final double price;
  final ShoppingItemStatus status;
  final int personNumber;
  final String? notes;
  final String? storageTips;
  final int? defaultShelfLifeDay;
  final int? categoryId;
  final QuantityUnit quantityUnit;
  final Image image;
  final String createdAt;
  final String updatedAt;

  ShoppingListItem({
    this.id,
    required this.foodName,
    this.shoppingListId,
    required this.recommendedQuantity,
    required this.price,
    required this.personNumber,
    required this.status,
    this.defaultShelfLifeDay,
    this.notes,
    this.storageTips,
    this.categoryId,
    required this.quantityUnit,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id']?.toString(),
      foodName: json['food_name'] ?? '',
      shoppingListId: json['shopping_list_id'] as int?,
      recommendedQuantity:
          (json['recommended_quantity'] as num?)?.toDouble() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      storageTips: json['storage_tips'] as String?,
      categoryId: json['food_category_id'] as int?,
      status: ShoppingItemStatus.values.byName(
        (json['status'] ?? 'UNPURCHASED').toLowerCase(),
      ),
      quantityUnit: QuantityUnit.values.byName(
        (json['unit'] ?? 'UNIT').toLowerCase(),
      ),
      personNumber: (json['person_number'] as num?)?.toInt() ?? 1,
      image: Image.fromJson(json['image'] as Map<String, dynamic>),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_name': foodName,
      'shopping_list_id': shoppingListId,
      'recommended_quantity': recommendedQuantity,
      'price': price,
      'status': status.name.toUpperCase(),
      'person_number': personNumber,
      'notes': notes,
      'storage_tips': storageTips,
      'default_shelf_life_day': defaultShelfLifeDay,
      'food_category_id': categoryId,
      'quantity_unit': quantityUnit.name.toUpperCase(),
      // 'image': image.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'ShoppingListItem{id: $id, foodName: $foodName, shoppingListId: $shoppingListId, recommendedQuantity: $recommendedQuantity, price: $price, status: $status, notes: $notes, storageTips: $storageTips, categoryId: $categoryId, categoryId: $categoryId, unit: $quantityUnit}';
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
      // 'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  // Return the number of items in the shopping list
  int get itemCount => items?.length ?? 0;

  @override
  String toString() {
    return 'ShoppingList{id: $id, weekNumber: $weekNumber, name: $name, status: $status, totalEstimatedCost: $totalEstimatedCost, userId: $userId, isCompleted: $isCompleted, itemCount: $itemCount}';
  }
}
