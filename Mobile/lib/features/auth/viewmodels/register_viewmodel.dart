import 'package:flutter/material.dart';

// Form data model
class SignupCredentials {
  String fullname = '';
  String email = '';
  String password = '';

  SignupCredentials({
    required this.fullname,
    required this.email,
    required this.password,
  });
}

class RegisterViewModel extends ChangeNotifier {
  final _formkey = GlobalKey<FormState>();
  final _credentials = SignupCredentials(fullname: '', email: '', password: '');

  //getters
  GlobalKey<FormState> get formkey => _formkey;

  //submit the submit form
  void submitLoginForm() {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      print(
        'email: ${_credentials.email} | mot de passe: ${_credentials.password} | nom complet: ${_credentials.fullname}',
      );
    }
  }

  void setFullname(String fullname) => _credentials.fullname = fullname;
  void setEmail(String email) => _credentials.email = email;
  void setPassword(String password) => _credentials.password = password;
}
