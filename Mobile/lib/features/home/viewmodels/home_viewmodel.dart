import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/user_model.dart';
import 'package:gaspika_mobile/utils/app_Loger.dart';

class HomeViewModel extends ChangeNotifier {
  UserModel _userModel = UserModel();
  bool _isLoadingUser = false;
  String? _userName;

  //getters
  bool get isLoadingUser => _isLoadingUser;
  String? get userName => _userName;

  //fetch user info
  Future fetchUserInfo() async {
    _isLoadingUser = true;
    notifyListeners();

    final response = await _userModel.getUserInfo();

    AppLogger.logger.i('User info response: $response');

    if (response.hasError == true) {
      _isLoadingUser = false;
      notifyListeners();
    }

    _isLoadingUser = false;
    _userName = response.data!.firstName;
    notifyListeners();
  }
}
