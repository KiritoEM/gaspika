class NotificationPreference {
  bool pushEnabled;
  bool foodExpirationEnabled;
  bool listExpirationEnabled;

  NotificationPreference({
    required this.pushEnabled,
    required this.foodExpirationEnabled,
    required this.listExpirationEnabled,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      pushEnabled: json['push_enabled'],
      foodExpirationEnabled: json['food_expiration_enabled'],
      listExpirationEnabled: json['list_expiration_enabled'],
    );
  }

  NotificationPreference copyWith({
    bool? pushEnabled,
    bool? foodExpirationEnabled,
    bool? listExpirationEnabled,
  }) {
    return NotificationPreference(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      foodExpirationEnabled:
          foodExpirationEnabled ?? this.foodExpirationEnabled,
      listExpirationEnabled:
          listExpirationEnabled ?? this.listExpirationEnabled,
    );
  }

  @override
  String toString() {
    return 'NotificationPreference{pushEnabled: $pushEnabled, foodExpirationEnabled: $foodExpirationEnabled, listExpirationEnabled: $listExpirationEnabled}';
  }
}
