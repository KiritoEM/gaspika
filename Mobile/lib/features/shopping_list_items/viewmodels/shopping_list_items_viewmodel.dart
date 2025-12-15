import 'package:flutter/material.dart';
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

  // Getters
  bool get isLoadingItems => _isLoadingItems;
  List<ShoppingListItem> get shoppingItems => _shoppingItems;

  // Get shopping items by list ID
  Future<void> fetchShoppingItemsById(int listId) async {
    _isLoadingItems = true;
    notifyListeners();

    final response = await _shoppingItemsModel.getShoppingItemsById(listId);

    if (response.hasError == true) {
      _isLoadingItems = false;
      notifyListeners();
      return;
    }

    _shoppingItems = response.data ?? [];
    _isLoadingItems = false;
    notifyListeners();
  }

  // Clear items when leaving the screen
  void clearItems() {
    _shoppingItems = [];
    _isLoadingItems = true;
    notifyListeners();
  }
}
