import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/auth_model.dart';
import 'package:gaspika_mobile/models/domains-object/user.dart';
import 'package:gaspika_mobile/models/user_model.dart';

class SettingsViewmodel extends ChangeNotifier {
  final UserModel _userModel = UserModel();
  final AuthModel _authModel = AuthModel();

  bool _isLoadingUser = true;
  User? _user;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  bool get isLoadingUser => _isLoadingUser;
  User? get user => _user;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Get user info
  Future fetchUserInfo() async {
    final response = await _userModel.getUserInfo();
    if (response.hasError == true) {
      _isLoadingUser = false;
      _hasError = true;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _user = response.data!;
    _isLoadingUser = false;
    notifyListeners();
  }

  // Logout
   Future logout() async {
    return await _authModel.logout();
  }
}
