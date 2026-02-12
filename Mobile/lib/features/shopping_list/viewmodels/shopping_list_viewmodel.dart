import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/shopping_list_model.dart';
import 'package:gaspika_mobile/utils/date.dart';
import 'package:intl/intl.dart';

class ShoppingListViewModel extends ChangeNotifier {
  // Models
  final ShoppingListModel _shoppingListModel = ShoppingListModel();

  late final TextEditingController listNameController;

  ShoppingListViewModel() {
    listNameController = TextEditingController(
      text:
          'Courses semaine ${DateFormat('dd/MM/yyyy').format(DateUtilities.startOfWeek(_selectedDate))}',
    );

    // add listener to listNameController
    listNameController.addListener(_onListNameChanged);
  }

  bool _isLoadingList = true;
  bool _isGeneratingList = false;
  bool _isDeletingList = false;

  bool _hasFetchError = false;
  String _fetchErrorMessage = '';
  NetworkErrorType? _fetchErrorType;

  bool _hasGenerateError = false;
  String _generateErrorMessage = '';
  NetworkErrorType? _generateErrorType;

  // Delete errors
  bool _hasDeleteError = false;
  String _deleteErrorMessage = '';
  NetworkErrorType? _deleteErrorType;

  List<ShoppingList> _shoppingWeekItems = [];
  DateTime _selectedDate = DateTime.now();
  ShoppingListStatus _statusFilter = ShoppingListStatus.all;

  // loading states
  bool get isLoadingList => _isLoadingList;
  bool get isGeneratingList => _isGeneratingList;
  bool get isDeletingList => _isDeletingList;

  // error states
  bool get hasFetchError => _hasFetchError;
  String get fetchErrorMessage => _fetchErrorMessage;
  NetworkErrorType? get fetchErrorType => _fetchErrorType;
  bool get hasGenerateError => _hasGenerateError;
  String get generateErrorMessage => _generateErrorMessage;
  NetworkErrorType? get generateErrorType => _generateErrorType;

  bool get hasDeleteError => _hasDeleteError;
  String get deleteErrorMessage => _deleteErrorMessage;
  NetworkErrorType? get deleteErrorType => _deleteErrorType;

  List<ShoppingList> get shoppingWeekItems => _shoppingWeekItems;
  DateTime get selectedDate => _selectedDate;
  ShoppingListStatus get statusFilter => _statusFilter;

  // Clear all errors
  void clearAllErrors() {
    _hasFetchError = false;
    _fetchErrorMessage = '';
    _fetchErrorType = null;

    _hasGenerateError = false;
    _generateErrorMessage = '';
    _generateErrorType = null;

    _hasDeleteError = false;
    _deleteErrorMessage = '';
    _deleteErrorType = null;

    notifyListeners();
  }

  // Get shopping list
  Future<void> fetchShoppingList() async {
    _shoppingWeekItems = [];
    _isLoadingList = true;
    _hasFetchError = false;
    _fetchErrorMessage = '';
    _fetchErrorType = null;
    notifyListeners();

    final response = await _shoppingListModel.getShoppingList(statusFilter);

    if (response.hasError == true) {
      _isLoadingList = false;
      _hasFetchError = true;
      _fetchErrorType = response.errorType;
      _fetchErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _shoppingWeekItems = response.data ?? [];

    await Future.delayed(Duration(seconds: 5));

    _isLoadingList = false;
    notifyListeners();
  }

  // Refresh shopping list
  Future<void> refreshShoppingList() async {
    _shoppingWeekItems = [];
    _isLoadingList = true;
    _hasFetchError = false;
    _fetchErrorMessage = '';
    _fetchErrorType = null;
    _statusFilter = ShoppingListStatus.all;
    clearAllErrors();
    notifyListeners();

    await fetchShoppingList();
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;

    listNameController.text =
        'Courses semaine ${DateFormat('dd/MM/yyyy').format(DateUtilities.startOfWeek(_selectedDate))}';

    notifyListeners();
  }

  // Generate shopping list
  Future<void> generateShoppingList() async {
    _isGeneratingList = true;
    _hasGenerateError = false;
    _generateErrorMessage = '';
    _generateErrorType = null;
    notifyListeners();

    final response = await _shoppingListModel.generateShoppingList(
      DateUtilities.getCurrentWeekNumberISO(date: _selectedDate),
      listNameController.text,
    );

    if (response.hasError == true) {
      _isGeneratingList = false;
      _hasGenerateError = true;
      _generateErrorType = response.errorType;
      _generateErrorMessage = response.message!;
      resetAllStates();

      notifyListeners();
      return;
    }

    _isGeneratingList = false;
    notifyListeners();

    refreshShoppingList();
  }

  // Delete list
  Future<void> deleteShoppingList(int id) async {
    _isDeletingList = true;
    _hasDeleteError = false;
    _deleteErrorMessage = '';
    _deleteErrorType = null;
    notifyListeners();

    final response = await _shoppingListModel.deteleShoppingList(id);

    if (response.hasError == true) {
      _isDeletingList = false;
      _hasDeleteError = true;
      _deleteErrorType = response.errorType;
      _deleteErrorMessage = response.message!;
      resetAllStates();

      notifyListeners();
      return;
    }

    _isDeletingList = false;
    resetAllStates();
    await refreshShoppingList();
  }

  // Handle change status filter
  Future<void> changeStatusFilter(ShoppingListStatus status) async {
    _isLoadingList = true;
    _hasFetchError = false;
    _fetchErrorMessage = '';
    _fetchErrorType = null;
    _statusFilter = status;
    notifyListeners();

    await fetchShoppingList();
  }

  void _onListNameChanged() {
    notifyListeners();
  }

  // reset all states
  void resetAllStates() {
    _selectedDate = DateTime.now();
    listNameController.text =
        'Courses semaine ${DateFormat('dd/MM/yyyy').format(DateUtilities.startOfWeek(_selectedDate))}';
    notifyListeners();
  }

  @override
  void dispose() {
    listNameController.dispose();
    super.dispose();
  }
}
