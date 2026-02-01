import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/auth_model.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/user_model.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';

class HomeViewModel extends ChangeNotifier {
  // Models
  final UserModel _userModel = UserModel();
  final AuthModel _authModel = AuthModel();
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();

  // User states
  bool _isLoadingUser = true;
  String? _userName;

  // Shopping states
  bool _isLoadingShopping = true;
  bool _isLoadingFoodCount = true;
  bool _hasError = false;
  String _errorMessage = '';
  NetworkErrorType? _errorType;
  int _availableFoodCount = 0;
  List<ShoppingListItem> _shoppingWeekItems = [];

  // getters
  bool get isLoadingUser => _isLoadingUser;
  bool get isLoadingShopping => _isLoadingShopping;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  NetworkErrorType? get errorType => _errorType;
  String? get userName => _userName;
  bool get isLoadingFoodCount => _isLoadingFoodCount;
  int get availableFoodCount => _availableFoodCount;
  List<ShoppingListItem> get shoppingWeekItems => _shoppingWeekItems;

  // get user info
  Future<void> fetchUserInfo() async {
    final response = await _userModel.getUserInfo();

    if (response.hasError == true) {
      _isLoadingUser = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _userName = response.data!.firstName;
    _isLoadingUser = false;
    notifyListeners();
  }

  // get available food count
  Future<void> fetchAvailableFoodCount() async {
    final response = await _shoppingItemsModel.getAvalaibleFoodCount();

    AppLogger.logger.i(response);

    if (response.hasError == true) {
      _isLoadingFoodCount = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _availableFoodCount = response.data ?? 0;
    _isLoadingFoodCount = false;
    notifyListeners();
  }

  // get shopping week items
  Future<void> fetchShoppingWeekItems() async {
    _isLoadingShopping = true;
    notifyListeners();

    final response = await _shoppingItemsModel.getShoppingWeekItems();

    if (response.hasError == true) {
      _isLoadingShopping = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _shoppingWeekItems = response.data ?? [];
    _isLoadingShopping = false;
    notifyListeners();
  }

  Future logout() {
    return _authModel.logout();
  }

  // refresh all requests
  Future refreshAll() async {
    // reset all states
    _isLoadingUser = true;
    _isLoadingFoodCount = true;
    _isLoadingShopping = true;
    _hasError = false;
    _errorMessage = '';
    _errorType = null;
    notifyListeners();

    await Future.wait([
      fetchUserInfo(),
      fetchAvailableFoodCount(),
      fetchShoppingWeekItems(),
    ]);
  }
}
