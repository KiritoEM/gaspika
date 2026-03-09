// Form data model
class LoginCredentials {
  String email = '';
  String password = '';
  String? fcmToken;

  LoginCredentials({
    required this.email,
    required this.password,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password, 'fcm_token': fcmToken};
  }

  LoginCredentials copyWith({
    String? email,
    String? password,
    String? fcmToken,
  }) {
    return LoginCredentials(
      email: email ?? this.email,
      password: password ?? this.password,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'LoginCredentials(email: $email, password: $password, fcm_token: $fcmToken)';
  }
}

class SignupCredentials {
  String fullname = '';
  String email = '';
  String password = '';
  // String? fcmToken;

  SignupCredentials({
    required this.fullname,
    required this.email,
    required this.password,
    // this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'fullname': fullname,
      // 'fcm_token': fcmToken,
    };
  }

  SignupCredentials copyWith({
    String? fullname,
    String? email,
    String? password,
    String? fcmToken,
  }) {
    return SignupCredentials(
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      password: password ?? this.password,
      // fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
