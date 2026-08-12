import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/models/schemas/change_password_schema.dart';
import 'package:gaspika_mobile/models/schemas/notification_preference_schema.dart';
import 'package:gaspika_mobile/models/schemas/update_user_schema.dart';

class UserService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await _dio.get(ApiConstant.USER_ME_ENDPOINT);

    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateUserInfo(UpdateUserSchema newData) async {
    final response = await _dio.patch(
      ApiConstant.USER_ME_ENDPOINT,
      data: newData.toMap(),
    );

    return response.data['data'];
  }

  Future changePassword(ChangePasswordSchema newData) async {
    await _dio.patch(
      ApiConstant.USER_PASSWORD_ENDPOINT,
      data: newData.toMap(),
    );
  }

  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final response = await _dio.get(
      ApiConstant.USER_NOTIFICATION_PREFERENCES_ENDPOINT,
    );

    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateNotificationPreferences(
    NotificationPreferenceSchema newData,
  ) async {
    final response = await _dio.patch(
      ApiConstant.USER_NOTIFICATION_PREFERENCES_ENDPOINT,
      data: newData.toMap(),
    );

    return response.data['data'];
  }

  Future deleteAccount(String password, String? fcmToken) async {
    await _dio.delete(
      ApiConstant.USER_ME_ENDPOINT,
      data: {'password': password, 'fcm_token': fcmToken},
    );
  }
}
