import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/shopping_list_model.dart';
import 'package:gaspika_mobile/utils/date.dart';
import 'package:intl/intl.dart';

class ShoppingListViewModel extends ChangeNotifier {
  // Models
  final ShoppingListModel _shoppingListModel = ShoppingListModel();

  late TextEditingController listNameController;

  ShoppingListViewModel() {
    listNameController = TextEditingController(
      text:
          'Courses semaine ${DateFormat('dd/MM/yyyy').format(DateUtilities.startOfWeek(_selectedDate))}',
    );
  }

  bool _isLoadingList = true;
  bool _isGeneratingList = false;
  bool _isDeletingList = false;
  bool _isUpdatingList = false;
  bool _hasFetchError = false;
  String _fetchErrorMessage = '';
  NetworkErrorType? _fetchErrorType;
  bool _hasGenerateError = false;
  String _generateErrorMessage = '';
  NetworkErrorType? _generateErrorType;
  bool _hasDeleteError = false;
  String _deleteErrorMessage = '';
  NetworkErrorType? _deleteErrorType;
  bool _hasUpdateError = false;
  String _updateErrorMessage = '';
  NetworkErrorType? _updateErrorType;
  PeriodFilterEnum? _periodFilter;
  List<ShoppingList> _shoppingWeekItems = [];
  DateTime _selectedDate = DateTime.now();
  ShoppingListStatus _statusFilter = ShoppingListStatus.all;

  // getters
  bool get isLoadingList => _isLoadingList;
  bool get isGeneratingList => _isGeneratingList;
  bool get isDeletingList => _isDeletingList;
  bool get isUpdatingList => _isUpdatingList;
  bool get hasFetchError => _hasFetchError;
  String get fetchErrorMessage => _fetchErrorMessage;
  NetworkErrorType? get fetchErrorType => _fetchErrorType;
  bool get hasGenerateError => _hasGenerateError;
  String get generateErrorMessage => _generateErrorMessage;
  NetworkErrorType? get generateErrorType => _generateErrorType;
  bool get hasUpdateError => _hasUpdateError;
  String get updateErrorMessage => _updateErrorMessage;
  NetworkErrorType? get updateErrorType => _updateErrorType;
  bool get hasDeleteError => _hasDeleteError;
  String get deleteErrorMessage => _deleteErrorMessage;
  NetworkErrorType? get deleteErrorType => _deleteErrorType;
  List<ShoppingList> get shoppingWeekItems => _shoppingWeekItems;
  DateTime get selectedDate => _selectedDate;
  ShoppingListStatus get statusFilter => _statusFilter;
  PeriodFilterEnum? get periodFilter => _periodFilter;

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
  Future fetchShoppingList() async {
    _shoppingWeekItems = [];
    _isLoadingList = true;
    _hasFetchError = false;
    _fetchErrorMessage = '';
    _fetchErrorType = null;
    notifyListeners();

    final response = await _shoppingListModel.getShoppingList(
      statusFilter,
      periodFilter,
    );

    if (response.hasError == true) {
      _isLoadingList = false;
      _hasFetchError = true;
      _fetchErrorType = response.errorType;
      _fetchErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _shoppingWeekItems = response.data ?? [];

    await Future.delayed(Duration(seconds: 3));

    _isLoadingList = false;
    notifyListeners();
  }

  // Refresh shopping list
  Future refreshShoppingList() async {
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
  Future generateShoppingList() async {
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
    listNameController.text = '';
    notifyListeners();

    refreshShoppingList();
  }

  // Delete list
  Future deleteShoppingList(int id) async {
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

      notifyListeners();
      return;
    }

    _isDeletingList = false;
    resetAllStates();

    await refreshShoppingList();
  }

  // update a shopping list
  Future updateShoppingList(int listId) async {
    _isUpdatingList = true;
    _hasUpdateError = false;
    _updateErrorMessage = '';
    _updateErrorType = null;
    notifyListeners();

    final response = await _shoppingListModel.updateShoppingList(
      listId,
      listNameController.text,
    );

    if (response.hasError == true) {
      _isUpdatingList = false;
      _hasUpdateError = true;
      _updateErrorType = response.errorType;
      _updateErrorMessage = response.message!;

      notifyListeners();
      return;
    }

    _isUpdatingList = false;
    resetAllStates();

    await refreshShoppingList();
  }

  // Handle change status filter
  Future changeStatusFilter(ShoppingListStatus status) async {
    _isLoadingList = true;
    _shoppingWeekItems = [];
    _fetchErrorMessage = '';
    _fetchErrorType = null;
    _hasFetchError = false;
    _statusFilter = status;
    notifyListeners();

    await fetchShoppingList();
  }

  // filter by period
  Future setFilterPeriod(PeriodFilterEnum? period) async {
    _isLoadingList = true;
    _shoppingWeekItems = [];
    _fetchErrorMessage = '';
    _fetchErrorType = null;
    _hasFetchError = false;
    _periodFilter = period;

    notifyListeners();

    await fetchShoppingList();
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
