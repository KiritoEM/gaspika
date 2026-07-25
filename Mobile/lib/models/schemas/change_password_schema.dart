class ChangePasswordSchema {
  String currentPassword;
  String newPassword;

  ChangePasswordSchema({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toMap() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}
