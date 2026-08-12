class Image {
  final String? id;
  final String filename;
  final String path;
  final int size;
  final String updatedAt;

  const Image({
    required this.filename,
    required this.size,
    required this.path,
    required this.updatedAt,
    this.id,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id']?.toString(),
      filename: json['filename'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] as int? ?? 0,
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'path': path,
      'size': size,
      'updated_at': updatedAt,
    };
  }
}
