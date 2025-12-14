// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/auth_model.dart';
import 'package:gaspika_mobile/models/schemas/auth_credentials.dart';
import 'package:gaspika_mobile/shared/snackbar.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/enums/enums.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthModel _authModel = AuthModel();
  final _formkey = GlobalKey<FormState>();
  final _credentials = SignupCredentials(fullname: '', email: '', password: '');
  bool _isSubmitting = false;

  // Getters
  bool get isSubmitting => _isSubmitting;
  GlobalKey<FormState> get formkey => _formkey;

  /// Submit the registration form
  Future<void> submitRegisterForm(BuildContext context) async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      _isSubmitting = true;
      notifyListeners();

      final response = await _authModel.register(_credentials);

      if (response.hasError == true) {
        _isSubmitting = false;
        SnackbarUtils.showInSnackBar(
          context,
          response.message!,
          type: SnackbarType.error,
        );
        notifyListeners();
        return;
      }

      SnackbarUtils.showInSnackBar(
        context,
        response.message!,
        type: SnackbarType.success,
      );

      context.go('/login');

      _formkey.currentState!.reset();
      _isSubmitting = false;
      notifyListeners();
    } else {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void setFullname(String fullname) => _credentials.fullname = fullname;
  void setEmail(String email) => _credentials.email = email;
  void setPassword(String password) => _credentials.password = password;
}
