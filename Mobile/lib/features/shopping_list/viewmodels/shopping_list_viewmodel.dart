import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/shopping_list_model.dart';
import 'package:gaspika_mobile/utils/app_Loger.dart';
import 'package:gaspika_mobile/utils/date.dart';

class VmReturn {
  bool? success;
  String? message;

  VmReturn({this.success, this.message});
}

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingListModel _shoppingListModel = ShoppingListModel();
  bool _isLoadingList = true;
  bool _isGeneratingList = false;
  List<ShoppingList> _shoppingWeekItems = [];
  DateTime _selectedDate = DateTime.now();

  // Getters
  bool get isLoadingList => _isLoadingList;
  bool get isGeneratingList => _isGeneratingList;
  List<ShoppingList> get shoppingWeekItems => _shoppingWeekItems;
  DateTime get selectedDate => _selectedDate;

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

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Generate shopping list
  Future<VmReturn> generateShoppingList() async {
    _isGeneratingList = true;
    notifyListeners();

    final response = await _shoppingListModel.generateShoppingList(
      DateUtilities.getCurrentWeekNumberISO(date: _selectedDate),
    );

    if (response.hasError == true) {
      _isGeneratingList = false;
      notifyListeners();
      return VmReturn(message: response.message, success: false);
    }

    fetchShoppingList(); // refresh
    _isGeneratingList = false;
    notifyListeners();

    return VmReturn(message: response.message, success: true);
  }
}
