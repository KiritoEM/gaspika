import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';

class VmReturn {
  bool? success;
  String? message;

  VmReturn({this.success, this.message});
}

class ShoppingItemsViewModel extends ChangeNotifier {
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();

  bool _isLoadingItems = true;
  List<ShoppingListItem> _shoppingItems = [];
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  bool get isLoadingItems => _isLoadingItems;
  List<ShoppingListItem> get shoppingItems => _shoppingItems;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // clear error
  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Get shopping items by list ID
  Future fetchShoppingItems(int listId) async {
    _isLoadingItems = true;
    clearError();
    notifyListeners();

    final response = await _shoppingItemsModel.getShoppingItems(listId);

    if (response.hasError == true) {
      _isLoadingItems = false;
      _hasError = true;
      _errorMessage = response.message!;
      notifyListeners();

      return;
    }

    _shoppingItems = response.data ?? [];
    _isLoadingItems = false;
    notifyListeners();
  }

  // Refresh shopping items
  Future refreshItems(int listId) async {
    _isLoadingItems = true;
    notifyListeners();

    await fetchShoppingItems(listId);
  }

  // refresh shopping items list
  Future refreshShoppingItems(int listId) async {
    _shoppingItems = [];
    _isLoadingItems = true;
    clearError();
    notifyListeners();

    await fetchShoppingItems(listId);
  }

  // Clear items when leaving the screen
  void clearItems() {
    _shoppingItems = [];
    _isLoadingItems = true;
    notifyListeners();
  }
}
