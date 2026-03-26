class Category {
  final int id;
  final String name;
  final String mlCategory;

  const Category({
    required this.name,
    required this.id,
    required this.mlCategory,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      mlCategory: json['ml_category'] ?? '',
    );
  }

  Category copyWith({int? id, String? name, String? mlCategory}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      mlCategory: mlCategory ?? this.mlCategory,
    );
  }
}
