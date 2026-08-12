import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/domains-object/notification.dart';
import 'package:gaspika_mobile/services/api/notifications_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';

class NotificationModel {
  final NotificationsService _notificationService = NotificationsService();

  Future<ApiResponse<int?>> getNotificationsCount() async {
    try {
      final response = await _notificationService.getNotificationsCount();
      return ApiResponse(
        data: response['count'] as int,
        message: 'Notifications récupérées avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e('DioException while fetching notifications count: ${err.response?.statusCode} - ${err.message}');
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType: NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching notifications count: $err');
      return ApiResponse(hasError: true, message: 'Impossible de récupérer le nombre de notifications.');
    }
  }

  Future<ApiResponse<List<NotificationSchema>>> getNotifications({int page = 1, int limit = 10}) async {
    try {
      final response = await _notificationService.getNotifications(page: page, limit: limit);
      await Future.delayed(const Duration(milliseconds: 200));
      final items = response.map((e) => NotificationSchema.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(data: items, message: 'Notifications récupérées avec succès.');
    } on DioException catch (err) {
      AppLogger.logger.e('DioException while fetching notifications: ${err.response?.statusCode} - ${err.message}');
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType: NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching notifications: $err');
      return ApiResponse(hasError: true, message: 'Impossible de récupérer les notifications.');
    }
  }

  Future<ApiResponse<String>> markAllAsRead() async {
    try {
      await _notificationService.markAllNotificationsAsRead();
      return ApiResponse(data: 'success', message: 'Toutes les notifications ont été marquées comme lues.');
    } on DioException catch (err) {
      AppLogger.logger.e('DioException while marking notifications as read: ${err.response?.statusCode} - ${err.message}');
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType: NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while marking notifications as read: $err');
      return ApiResponse(hasError: true, message: 'Impossible de marquer les notifications comme lues.');
    }
  }

  Future<ApiResponse<String>> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationsAsRead(notificationId);
      return ApiResponse(data: 'success', message: 'La notification a été marquée comme lue.');
    } on DioException catch (err) {
      AppLogger.logger.e('DioException while marking notification as read: ${err.response?.statusCode} - ${err.message}');
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType: NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while marking notification as read: $err');
      return ApiResponse(hasError: true, message: 'Impossible de marquer la notification comme lue.');
    }
  }

  Future<ApiResponse<String>> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      return ApiResponse(data: 'success', message: 'La notification a été supprimée.');
    } on DioException catch (err) {
      AppLogger.logger.e('DioException while deleting notification: ${err.response?.statusCode} - ${err.message}');
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType: NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while deleting notification: $err');
      return ApiResponse(hasError: true, message: 'Impossible de supprimer la notification.');
    }
  }
}
