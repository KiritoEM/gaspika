import 'package:flutter/material.dart';

// Form data model
class LoginCredentials {
  String email = '';
  String password = '';
  LoginCredentials({required this.email, required this.password});
}

class LoginViewModel extends ChangeNotifier {
  final _formkey = GlobalKey<FormState>();
  final _credentials = LoginCredentials(email: '', password: '');

  //submit the login form
  void submitLoginForm() {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      print(
        'email: ${_credentials.email} and password: ${_credentials.password}',
      );
    }
  }
}
