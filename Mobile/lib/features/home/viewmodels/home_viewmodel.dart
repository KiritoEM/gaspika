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
  bool _isLoadingUser = true;
  String? _userName;

  // Shopping states
  bool _isLoadingShopping = true;
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
}
