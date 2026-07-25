class NotificationPreferenceSchema {
  bool? pushEnabled;
  bool? foodExpirationEnabled;
  bool? listExpirationEnabled;

  NotificationPreferenceSchema({
    this.pushEnabled,
    this.foodExpirationEnabled,
    this.listExpirationEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      if (pushEnabled != null) 'push_enabled': pushEnabled,
      if (foodExpirationEnabled != null)
        'food_expiration_enabled': foodExpirationEnabled,
      if (listExpirationEnabled != null)
        'list_expiration_enabled': listExpirationEnabled,
    };
  }
}
