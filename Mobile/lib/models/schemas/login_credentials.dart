// Form data model
class LoginCredentials {
  String email = '';
  String password = '';

  LoginCredentials({required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }
}
