import 'package:flutter/material.dart';
import 'package:gaspika_mobile/models/domains-object/notification.dart';
import 'package:gaspika_mobile/models/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationModel _notificationModel = NotificationModel();

  bool _isLoadingNotifications = true;
  bool _isMarkingAllAsRead = false;
  bool _isMarkingAsRead = false;
  bool _isDeletingNotification = false;
  bool _hasFetchError = false;
  String _fetchErrorMessage = '';
  bool _hasMarkAllAsReadError = false;
  String _markAllAsReadErrorMessage = '';
  bool _hasMarkAsReadError = false;
  String _markAsReadErrorMessage = '';
  bool _hasDeleteError = false;
  String _deleteErrorMessage = '';
  List<NotificationSchema> _notifications = [];
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  // Getters
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool get isMarkingAllAsRead => _isMarkingAllAsRead;
  bool get isMarkingAsRead => _isMarkingAsRead;
  bool get isDeletingNotification => _isDeletingNotification;
  bool get hasFetchError => _hasFetchError;
  String get fetchErrorMessage => _fetchErrorMessage;
  bool get hasMarkAllAsReadError => _hasMarkAllAsReadError;
  String get markAllAsReadErrorMessage => _markAllAsReadErrorMessage;
  bool get hasMarkAsReadError => _hasMarkAsReadError;
  String get markAsReadErrorMessage => _markAsReadErrorMessage;
  bool get hasDeleteError => _hasDeleteError;
  String get deleteErrorMessage => _deleteErrorMessage;
  List<NotificationSchema> get notifications => _notifications;
  bool get hasMore => _hasMore;

  // Clear all errors
  void clearAllErrors() {
    _hasFetchError = false;
    _fetchErrorMessage = '';
    _hasMarkAllAsReadError = false;
    _markAllAsReadErrorMessage = '';
    _hasMarkAsReadError = false;
    _markAsReadErrorMessage = '';
    _hasDeleteError = false;
    _deleteErrorMessage = '';
    notifyListeners();
  }

  // Fetch notifications
  Future fetchNotifications() async {
    _isLoadingNotifications = true;
    _currentPage = 1;
    _hasMore = true;
    _hasFetchError = false;
    _fetchErrorMessage = '';
    notifyListeners();

    final response = await _notificationModel.getNotifications(
      page: _currentPage,
      limit: _limit,
    );

    if (response.hasError == true) {
      _isLoadingNotifications = false;
      _hasFetchError = true;
      _fetchErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _notifications = response.data ?? [];
    _hasMore = _notifications.length >= _limit;
    _isLoadingNotifications = false;
    notifyListeners();
  }

  // Load more (pagination)
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
      _hasFetchError = true;
      _fetchErrorMessage = response.message!;
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
    _hasMarkAllAsReadError = false;
    _markAllAsReadErrorMessage = '';
    notifyListeners();

    final response = await _notificationModel.markAllAsRead();

    if (response.hasError == true) {
      _isMarkingAllAsRead = false;
      _hasMarkAllAsReadError = true;
      _markAllAsReadErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _notifications = _notifications
        .map(
          (notif) => NotificationSchema(
            id: notif.id,
            body: notif.body,
            image: notif.image,
            route: notif.route,
            isRead: true,
            type: notif.type,
            createdAt: notif.createdAt,
          ),
        )
        .toList();

    _isMarkingAllAsRead = false;
    notifyListeners();
  }

  // Mark single notification as read
  Future markNotificationAsRead(String notificationId) async {
    _isMarkingAsRead = true;
    _hasMarkAsReadError = false;
    _markAsReadErrorMessage = '';
    notifyListeners();

    final response = await _notificationModel.markNotificationAsRead(
      notificationId,
    );

    if (response.hasError == true) {
      _isMarkingAsRead = false;
      _hasMarkAsReadError = true;
      _markAsReadErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _notifications = _notifications
        .map(
          (notif) => notif.id == notificationId
              ? NotificationSchema(
                  id: notif.id,
                  body: notif.body,
                  image: notif.image,
                  route: notif.route,
                  isRead: true,
                  type: notif.type,
                  createdAt: notif.createdAt,
                )
              : notif,
        )
        .toList();

    _isMarkingAsRead = false;
    notifyListeners();
  }

  // Delete notification
  Future deleteNotification(String notificationId) async {
    _isDeletingNotification = true;
    _hasDeleteError = false;
    _deleteErrorMessage = '';
    notifyListeners();

    final response = await _notificationModel.deleteNotification(
      notificationId,
    );

    if (response.hasError == true) {
      _isDeletingNotification = false;
      _hasDeleteError = true;
      _deleteErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _notifications = _notifications
        .where((notif) => notif.id != notificationId)
        .toList();

    _isDeletingNotification = false;
    notifyListeners();
  }

  // Refresh all
  Future refreshAll() async {
    _isLoadingNotifications = true;
    clearAllErrors();
    notifyListeners();

    await fetchNotifications();
  }
}
