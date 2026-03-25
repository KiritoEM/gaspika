import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/domains-object/notification.dart';
import 'package:gaspika_mobile/models/notification_model.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';

class NotificationViewModel extends ChangeNotifier {
  // Model
  final NotificationModel _notificationModel = NotificationModel();

  // States
  bool _isLoadingCount = true;
  bool _isLoadingNotifications = true;
  bool _isMarkingAllAsRead = false;
  bool _hasError = false;
  String _errorMessage = '';
  NetworkErrorType? _errorType;
  List<NotificationSchema> _notifications = [];

  // Pagination
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  // Getters
  bool get isLoadingCount => _isLoadingCount;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool get isMarkingAllAsRead => _isMarkingAllAsRead;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  NetworkErrorType? get errorType => _errorType;
  List<NotificationSchema> get notifications => _notifications;
  bool get hasMore => _hasMore;

  // Fetch notifications
  Future fetchNotifications() async {
    _isLoadingNotifications = true;
    _currentPage = 1;
    _hasMore = true;
    _hasError = false;
    notifyListeners();

    final response = await _notificationModel.getNotifications(
      page: _currentPage,
      limit: _limit,
    );

    AppLogger.logger.i(response);

    if (response.hasError == true) {
      _isLoadingNotifications = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _notifications = response.data ?? [];
    _hasMore = _notifications.length >= _limit;
    _isLoadingNotifications = false;
    notifyListeners();
  }

  // Load more notifications (pagination)
  Future loadMore() async {
    if (!_hasMore || _isLoadingNotifications) return;

    _currentPage++;
    notifyListeners();

    final response = await _notificationModel.getNotifications(
      page: _currentPage,
      limit: _limit,
    );

    if (response.hasError == true) {
      _currentPage--;
      notifyListeners();
      return;
    }

    final newItems = response.data ?? [];
    _notifications.addAll(newItems);
    _hasMore = newItems.length >= _limit;
    notifyListeners();
  }

  // Mark all as read
  Future markAllAsRead() async {
    _isMarkingAllAsRead = true;
    notifyListeners();

    final response = await _notificationModel.markAllAsRead();

    if (response.hasError == true) {
      _isMarkingAllAsRead = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _notifications = _notifications
        .map(
          (n) => NotificationSchema(
            id: n.id,
            body: n.body,
            image: n.image,
            route: n.route,
            isRead: true,
            type: n.type,
            createdAt: n.createdAt,
          ),
        )
        .toList();

    _isMarkingAllAsRead = false;
    notifyListeners();
  }

  // Refresh all
  Future refreshAll() async {
    _isLoadingCount = true;
    _isLoadingNotifications = true;
    _hasError = false;
    _errorMessage = '';
    _errorType = null;
    notifyListeners();

    await Future.wait([fetchNotifications()]);
  }
}
