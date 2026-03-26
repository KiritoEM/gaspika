import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/schemas/update_item_schema.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';

class FoodDetailsViewmodel extends ChangeNotifier {
  // Models
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();

  // text controllers
  TextEditingController itemNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  bool _isLoadingItem = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDeletingItem = false;
  bool _hasDeleteError = false;
  String _deleteErrorMessage = '';
  bool _isMarkingItem = false;
  bool _hasMarkError = false;
  String _markErrorMessage = '';
  bool _isUpdatingItem = false;
  bool _hasUpdateError = false;
  String _updateErrorMessage = '';
  ShoppingListItem? _currentItem;

  // Getters
  bool get isLoadingItem => _isLoadingItem;
  bool get isDeletingItem => _isDeletingItem;
  bool get isMarkingItem => _isMarkingItem;
  bool get hasMarkError => _hasMarkError;
  String get markErrorMessage => _markErrorMessage;
  String get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  String get deleteErrorMessage => _deleteErrorMessage;
  bool get hasDeleteError => _hasDeleteError;
  bool get isUpdatingItem => _isUpdatingItem;
  bool get hasUpdateError => _hasUpdateError;
  String get updateErrorMessage => _updateErrorMessage;
  ShoppingListItem? get currentItem => _currentItem;

  // Clear error
  void clearError() {
    _hasError = false;
    _errorMessage = '';

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
      _hasMarkError = true;
      _markErrorMessage = response.message!;
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

  // update item
  Future updateItem(int itemId) async {
    _isUpdatingItem = true;
    _hasUpdateError = false;
    _updateErrorMessage = '';
    notifyListeners();

    final response = await _shoppingItemsModel.updateShoppingItem(
      itemId,
      UpdateShoppingItemSchema(
        foodName: itemNameController.text,
        price: double.tryParse(priceController.text) ?? 0,
        quantity: double.tryParse(quantityController.text) ?? 0,
      ),
    );

    if (response.hasError == true) {
      _isUpdatingItem = false;
      _hasUpdateError = true;
      _updateErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _isLoadingItem = false;
    notifyListeners();

    await refreshItem(itemId);
  }

  // delete item
  Future deleteItem(int itemId) async {
    _isDeletingItem = true;
    _hasDeleteError = false;
    _deleteErrorMessage = '';
    notifyListeners();

    final response = await _shoppingItemsModel.deteleShoppingItem(itemId);

    if (response.hasError == true) {
      _isDeletingItem = false;
      _hasDeleteError = true;
      _deleteErrorMessage = response.message!;

      notifyListeners();
      return;
    }

    _isDeletingItem = false;
    notifyListeners();
  }

  @override
  void dispose() {
    itemNameController.dispose();
    priceController.dispose();
    quantityController.dispose();

    super.dispose();
  }
}
