class Category {
  final String? id;
  final String name;

  const Category({required this.name, this.id});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id']?.toString(), name: json['name'] ?? '');
  }
}
