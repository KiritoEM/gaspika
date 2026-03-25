import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';

class NotificationsService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> getNotificationsCount() async {
    final response = await _dio.get(
      '${ApiConstant.NOTIFICATION_ENDPOINT}/unread',
    );

    return response.data;
  }

  Future<List<dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiConstant.NOTIFICATION_ENDPOINT,
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data['data'] as List<dynamic>;
  }

  Future markAllNotificationsAsRead() async {
    await _dio.patch('${ApiConstant.NOTIFICATION_ENDPOINT}/read-all');
  }
}
