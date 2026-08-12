import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/utils/app_Loger.dart';

class NotificationsService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> getNotificationsCount() async {
    final response = await _dio.get(
      '${ApiConstant.NOTIFICATION_ENDPOINT}/unread',
    );

    AppLogger.logger.w('Notification count: ${response.data}');

    return response.data;
  }

  Future<List<dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiConstant.NOTIFICATION_ENDPOINT,
      queryParameters: {'page': page, 'limit': limit},
    );

    return response.data['results'] as List<dynamic>;
  }

  Future markAllNotificationsAsRead() async {
    await _dio.patch('${ApiConstant.NOTIFICATION_ENDPOINT}/read-all');
  }

  Future markNotificationsAsRead(String notificationId) async {
    await _dio.patch(
      '${ApiConstant.NOTIFICATION_ENDPOINT}/$notificationId/read',
    );
  }

  Future deleteNotification(String notificationId) async {
    await _dio.delete('${ApiConstant.NOTIFICATION_ENDPOINT}/$notificationId');
  }
}
