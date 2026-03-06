import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';

class FoodDetailsViewmodel extends ChangeNotifier {
  // Models
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();

  bool _isLoadingItem = true;
  bool _hasError = false;
  String _errorMessage = '';
  NetworkErrorType? _errorType;
  bool _isDeletingItem = true;
  bool _hasDeleteError = false;
  String _deleteErrorMessage = '';
  NetworkErrorType? _deleteErrorType;
  bool _isMarkingItem = false;
  ShoppingListItem? _currentItem;

  // Getters
  bool get isLoadingItem => _isLoadingItem;
  bool get isDeletingItem => _isDeletingItem;
  bool get isMarkingItem => _isMarkingItem;
  String get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  String get deleteErrorMessage => _deleteErrorMessage;
  bool get hasDeleteError => _hasDeleteError;
  NetworkErrorType? get errorType => _errorType;
  ShoppingListItem? get currentItem => _currentItem;

  // Clear error
  void clearError() {
    _hasError = false;
    _errorMessage = '';
    _errorType = null;
    notifyListeners();
  }

  // Fetch item details
  Future fetchItemDetails(int itemId) async {
    _currentItem = null;
    _isLoadingItem = true;
    clearError();
    notifyListeners();

    final response = await _shoppingItemsModel.getShoppingItemById(itemId);

    if (response.hasError == true) {
      _isLoadingItem = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _currentItem = response.data;
    _isLoadingItem = false;
    notifyListeners();
  }

  // Fetch item details
  Future markItemAsComplete(int itemId) async {
    clearError();
    _isMarkingItem = true;
    notifyListeners();

    final response = await _shoppingItemsModel.markAsComplete(itemId);

    if (response.hasError == true) {
      _isMarkingItem = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _isMarkingItem = false;

    notifyListeners();
  }

  // Refresh item
  Future refreshItem(int itemId) async {
    _isLoadingItem = true;
    clearError();
    notifyListeners();
    await fetchItemDetails(itemId);
  }

  // Clear data
  void clearItemData() {
    _currentItem = null;
    _isLoadingItem = true;
    clearError();
    notifyListeners();
  }

  // delete item
  Future deleteItem(int itemId) async {
    _isDeletingItem = true;
    _hasDeleteError = false;
    _deleteErrorMessage = '';
    _deleteErrorType = null;
    notifyListeners();

    final response = await _shoppingItemsModel.deteleShoppingItem(itemId);

    if (response.hasError == true) {
      _isDeletingItem = false;
      _hasDeleteError = true;
      _deleteErrorType = response.errorType;
      _deleteErrorMessage = response.message!;

      notifyListeners();
      return;
    }

    _isDeletingItem = false;
    notifyListeners();
  }
}
