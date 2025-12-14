// Form data model
class LoginCredentials {
  String email = '';
  String password = '';

  LoginCredentials({required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }
}

class SignupCredentials {
  String fullname = '';
  String email = '';
  String password = '';

  SignupCredentials({
    required this.fullname,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password, 'fullname': fullname};
  }
}
