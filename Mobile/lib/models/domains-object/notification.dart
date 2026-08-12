import 'package:gaspika_mobile/constants/enums/enums.dart';

class NotificationSchema {
  final String id;
  final String body;
  final String? image;
  final String? route;
  final bool isRead;
  final NotificationTypeEnum type;
  final String createdAt;

  NotificationSchema({
    required this.id,
    required this.body,
    this.image,
    this.route,
    required this.isRead,
    required this.type,
    required this.createdAt,
  });

  factory NotificationSchema.fromJson(Map<String, dynamic> json) {
    return NotificationSchema(
      id: json['id'] as String,
      body: json['body'] as String,
      image: json['image'] as String?,
      route: json['route'] as String?,
      isRead: json['is_read'] as bool,
      type: NotificationTypeEnum.values.byName(
        (json['type'] ?? 'FOOD_EXPIRATION=').toLowerCase(),
      ),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'image': image,
      'route': route,
      'is_read': isRead,
      'type': type.name.toUpperCase(),
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'Notification{id: $id, body: $body, type: $type, isRead: $isRead, createdAt: $createdAt}';
  }
}
