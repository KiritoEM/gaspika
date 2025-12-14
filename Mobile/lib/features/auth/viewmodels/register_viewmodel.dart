// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/auth_model.dart';
import 'package:gaspika_mobile/models/schemas/auth_credentials.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthModel _authModel = AuthModel();
  final _formkey = GlobalKey<FormState>();
  final _credentials = SignupCredentials(fullname: '', email: '', password: '');
  bool _isSubmitting = false;

  // Getters
  bool get isSubmitting => _isSubmitting;
  GlobalKey<FormState> get formkey => _formkey;

  /// Submit the registration form
  Future<String?> submitRegisterForm() async {
    _isSubmitting = true;
    notifyListeners();

    if (!_formkey.currentState!.validate()) {
      _isSubmitting = false;
      notifyListeners();
      return null;
    }

    _formkey.currentState!.save();

    final response = await _authModel.register(_credentials);

    _isSubmitting = false;
    notifyListeners();

    if (response.hasError == true) {
      return response.message!;
    }

    _formkey.currentState!.reset();
    return null;
  }

  void setFullname(String fullname) => _credentials.fullname = fullname;
  void setEmail(String email) => _credentials.email = email;
  void setPassword(String password) => _credentials.password = password;
}
