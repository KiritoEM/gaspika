import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/shopping_list_model.dart';
import 'package:gaspika_mobile/utils/app_Loger.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingListModel _shoppingListModel = ShoppingListModel();
  bool _isLoadingList = true;
  List<ShoppingList> _shoppingWeekItems = [];

  // Getters
  bool get isLoadingList => _isLoadingList;
  List<ShoppingList> get shoppingWeekItems => _shoppingWeekItems;

  // Get shopping list
  Future<void> fetchShoppingList() async {
    final response = await _shoppingListModel.getShoppingList();

    AppLogger.logger.i('Shopping list: ${response.data}');

    if (response.hasError == true) {
      _isLoadingList = false;
      notifyListeners();
      return;
    }

    _shoppingWeekItems = response.data ?? [];
    _isLoadingList = false;
    notifyListeners();
  }
}
