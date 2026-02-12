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
  final Image? image;
  final int? conservationDuration;
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
    this.conservationDuration,
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
      image: json['image'] != null
          ? Image.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      conservationDuration: json['default_shelf_life_day'] as int?,
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
  final ShoppingListStatus status;
  final double totalEstimatedCost;
  final String? userId;
  final int itemsCount;
  final String createdAt;
  final String updatedAt;

  ShoppingList({
    this.id,
    required this.weekNumber,
    this.name,
    required this.status,
    this.totalEstimatedCost = 0,
    this.userId,
    this.itemsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as int?,
      weekNumber: json['week_number'] as int,
      name: json['name'] as String?,
      status: ShoppingListStatus.values.byName(
        (json['status'] ?? 'UNFINISHED').toLowerCase(),
      ),
      totalEstimatedCost:
          (json['total_estimated_cost'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id'] as String?,
      itemsCount: (json['items_count'] as int?) ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_number': weekNumber,
      'name': name,
      'status': status.name.toUpperCase(),
      'total_estimated_cost': totalEstimatedCost,
      'user_id': userId,
      'items_count': itemsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
