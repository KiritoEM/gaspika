import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/auth_model.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/user_model.dart';
import 'package:gaspika_mobile/models/shopping_items_model.dart';
import 'package:gaspika_mobile/models/notification_model.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';

class HomeViewModel extends ChangeNotifier {
  // Models
  final UserModel _userModel = UserModel();
  final AuthModel _authModel = AuthModel();
  final ShoppingItemsModel _shoppingItemsModel = ShoppingItemsModel();
  final NotificationModel _notificationModel = NotificationModel();

  // User states
  bool _isLoadingUser = true;
  String? _userName;

  // Shopping states
  bool _isLoadingShopping = true;
  bool _isLoadingFoodCount = true;
  bool _hasError = false;
  String _errorMessage = '';
  NetworkErrorType? _errorType;
  int _availableFoodCount = 0;
  List<ShoppingListItem> _shoppingWeekItems = [];

  // Notification states
  bool _isLoadingNotificationCount = true;
  int _notificationCount = 0;

  // Getters
  bool get isLoadingUser => _isLoadingUser;
  bool get isLoadingShopping => _isLoadingShopping;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  NetworkErrorType? get errorType => _errorType;
  String? get userName => _userName;
  bool get isLoadingFoodCount => _isLoadingFoodCount;
  int get availableFoodCount => _availableFoodCount;
  List<ShoppingListItem> get shoppingWeekItems => _shoppingWeekItems;
  bool get isLoadingNotificationCount => _isLoadingNotificationCount;
  int get notificationCount => _notificationCount;

  // Get user info
  Future fetchUserInfo() async {
    final response = await _userModel.getUserInfo();
    if (response.hasError == true) {
      _isLoadingUser = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }
    _userName = response.data!.firstName;
    _isLoadingUser = false;
    notifyListeners();
  }

  // Get available food count
  Future fetchAvailableFoodCount() async {
    final response = await _shoppingItemsModel.getAvalaibleFoodCount();
    AppLogger.logger.i(response);
    if (response.hasError == true) {
      _isLoadingFoodCount = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }
    _availableFoodCount = response.data ?? 0;
    _isLoadingFoodCount = false;
    notifyListeners();
  }

  // Get shopping week items
  Future fetchShoppingWeekItems() async {
    _isLoadingShopping = true;
    notifyListeners();
    final response = await _shoppingItemsModel.getShoppingWeekItems();
    if (response.hasError == true) {
      _isLoadingShopping = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }
    _shoppingWeekItems = response.data ?? [];
    _isLoadingShopping = false;
    notifyListeners();
  }

  // Get notification count
  Future fetchNotificationCount() async {
    final response = await _notificationModel.getNotificationsCount();
    if (response.hasError == true) {
      _isLoadingNotificationCount = false;
      notifyListeners();
      return;
    }
    _notificationCount = response.data ?? 0;
    _isLoadingNotificationCount = false;
    notifyListeners();
  }

  Future logout() {
    return _authModel.logout();
  }

  // Refresh all requests
  Future refreshAll() async {
    _isLoadingUser = true;
    _isLoadingFoodCount = true;
    _isLoadingShopping = true;
    _isLoadingNotificationCount = true;
    _hasError = false;
    _errorMessage = '';
    _errorType = null;
    notifyListeners();
    await Future.wait([
      fetchUserInfo(),
      fetchAvailableFoodCount(),
      fetchShoppingWeekItems(),
      fetchNotificationCount(),
    ]);
  }
}
