import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/schemas/createItem.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';

class CreateShoppingItemViewModel extends ChangeNotifier {
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CreateShoppingItemSchema _data = CreateShoppingItemSchema();

  bool _isSubmitting = false;

  String get name => _data.productName;
  String get price => _data.price.toString();
  String get quantity => _data.estimatedQuantity.toString();
  QuantityUnit get unit => _data.unit;
  String get notes => _data.notes;
  String get storageTips => _data.storageTips;
  int get categoryId => _data.categoryId;

  bool get isSubmitting => _isSubmitting;
  GlobalKey<FormState> get formKey => _formKey;

  void setName(String value) {
    _data.productName = value.trim();
    notifyListeners();
  }

  void setPrice(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    _data.price = double.tryParse(cleaned) ?? 0.0;
    notifyListeners();
  }

  void setQuantity(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    _data.estimatedQuantity = double.tryParse(cleaned) ?? 0.0;
    notifyListeners();
  }

  void setUnit(QuantityUnit? unit) {
    if (unit != null) {
      _data.unit = unit;
      notifyListeners();
    }
  }

  void setNotes(String value) {
    _data.notes = value.trim();
    notifyListeners();
  }

  void setStorageTips(String value) {
    _data.storageTips = value.trim();
    notifyListeners();
  }

  void setCategoryId(int id) {
    _data.categoryId = id;
    notifyListeners();
  }

  Future<String?> submitItemForm(int listId) async {
    _isSubmitting = true;
    notifyListeners();

    if (!_formKey.currentState!.validate()) {
      _isSubmitting = false;
      notifyListeners();
      return null;
    }

    if (_data.productName.isEmpty) {
      _isSubmitting = false;
      notifyListeners();
      return 'Le nom du produit est requis';
    }

    if (_data.price < 0) {
      _isSubmitting = false;
      notifyListeners();
      return 'Prix invalide';
    }

    if (_data.estimatedQuantity <= 0) {
      _isSubmitting = false;
      notifyListeners();
      return 'Quantité invalide ou nulle';
    }

    final response = await _shoppingItemsModel.createShoppingItem(
      _data,
      listId,
    );

    _isSubmitting = false;
    notifyListeners();

    if (response.hasError == true) {
      return response.message ?? 'Erreur inconnue lors de l\'ajout';
    }

    reset();
    return null;
  }

  void reset() {
    _data = CreateShoppingItemSchema();
    _formKey.currentState?.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
