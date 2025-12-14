class ShoppingListItem {
  final int id;
  final String productName;
  final int shoppingListId;
  final int estimatedQuantity;
  final int price;
  final bool isPurchased;
  final String? notes;
  final String? storageTips;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? categoryId;
  final String? category;

  ShoppingListItem({
    required this.id,
    required this.productName,
    required this.shoppingListId,
    required this.estimatedQuantity,
    required this.price,
    required this.isPurchased,
    this.notes,
    this.storageTips,
    this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.category,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'],
      productName: json['product_name'],
      shoppingListId: json['shopping_list_id'],
      estimatedQuantity: json['estimated_quantity'] ?? 1,
      price: json['price'] ?? 0,
      isPurchased: json['is_purchased'],
      notes: json['notes'],
      storageTips: json['storage_tips'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      categoryId: json['category_id'],
      category: json['category'],
    );
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category_id': categoryId,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'ShoppingListItem{id: $id, productName: $productName, shoppingListId: $shoppingListId, estimatedQuantity: $estimatedQuantity, price: $price, isPurchased: $isPurchased, notes: $notes, storageTips: $storageTips, createdAt: $createdAt, updatedAt: $updatedAt, categoryId: $categoryId, category: $category}';
  }
}
