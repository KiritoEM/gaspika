import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/auth_model.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/user_model.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';

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
  int _availableFoodCount = 0;
  List<ShoppingListItem> _shoppingWeekItems = [];

  // getters
  bool get isLoadingUser => _isLoadingUser;
  bool get isLoadingShopping => _isLoadingShopping;
  String? get userName => _userName;
  bool get isLoadingFoodCount => _isLoadingFoodCount;
  int get availableFoodCount => _availableFoodCount;
  List<ShoppingListItem> get shoppingWeekItems => _shoppingWeekItems;

  // get user info
  Future<void> fetchUserInfo() async {
    final response = await _userModel.getUserInfo();

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
    final response = await _shoppingItemsModel.getAvalaibleFoodCount();

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

    if (response.hasError == true) {
      _isLoadingShopping = false;
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
}
