import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/user_model.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';

class HomeViewModel extends ChangeNotifier {
  // MODELS
  final UserModel _userModel = UserModel();
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();

  // User states
  bool _isLoadingUser = false;
  String? _userName;

  // Shopping states
  bool _isLoadingShopping = false;
  int _availableFoodCount = 0;
  List<ShoppingListItem> _shoppingWeekItems = [];

  // getters
  bool get isLoadingUser => _isLoadingUser;
  bool get isLoadingShopping => _isLoadingShopping;

  String? get userName => _userName;
  int get availableFoodCount => _availableFoodCount;
  List<ShoppingListItem> get shoppingWeekItems => _shoppingWeekItems;

  // get user info
  Future<void> fetchUserInfo() async {
    _isLoadingUser = true;
    notifyListeners();

    final response = await _userModel.getUserInfo();
    AppLogger.logger.i('User info response: $response');

    if (response.hasError == true) {
      _isLoadingUser = false;
      notifyListeners();
      return;
    }

    _userName = response.data!.firstName;
    _isLoadingUser = false;
    notifyListeners();
  }

  // get available food count
  Future<void> fetchAvailableFoodCount() async {
    _isLoadingShopping = true;
    notifyListeners();

    final response = await _shoppingItemsModel.getAvalaibleFoodCount();

    AppLogger.logger.i('Available food count response: $response');

    if (response.hasError == true) {
      _isLoadingShopping = false;
      notifyListeners();
      return;
    }

    _availableFoodCount = response.data ?? 0;
    _isLoadingShopping = false;
    notifyListeners();
  }

  // get shopping week items
  Future<void> fetchShoppingWeekItems() async {
    _isLoadingShopping = true;
    notifyListeners();

    final response = await _shoppingItemsModel.getShoppingWeekItems();

    AppLogger.logger.i('Shopping week items response: $response');

    if (response.hasError == true) {
      _isLoadingShopping = false;
      notifyListeners();
      return;
    }

    _shoppingWeekItems = response.data ?? [];
    _isLoadingShopping = false;
    notifyListeners();
  }
}
