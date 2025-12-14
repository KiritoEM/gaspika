// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/auth_model.dart';
import 'package:gaspika_mobile/models/schemas/auth_credentials.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthModel _authModel = AuthModel();
  final _formkey = GlobalKey<FormState>();
  final _credentials = LoginCredentials(email: '', password: '');
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;
  GlobalKey<FormState> get formkey => _formkey;

  Future<String?> submitLoginForm() async {
    _isSubmitting = true;
    notifyListeners();

    if (!_formkey.currentState!.validate()) {
      _isSubmitting = false;
      notifyListeners();
      return null;
    }

    _formkey.currentState!.save();

    final response = await _authModel.login(_credentials);

    _isSubmitting = false;
    notifyListeners();

    if (response.hasError == true) {
      return response.message;
    }

    _formkey.currentState!.reset();
    return null; 
  }

  void setEmail(String email) => _credentials.email = email;
  void setPassword(String password) => _credentials.password = password;
}
