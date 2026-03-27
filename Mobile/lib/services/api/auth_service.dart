import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/models/schemas/auth_credentials.dart';

class AuthService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> login(LoginCredentials credentials) async {
    final response = await _dio.post(
      ApiConstant.LOGIN_ENDPOINT,
      data: credentials.toMap(),
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(SignupCredentials credentials) async {
    final List<String> nameParts = credentials.fullname.split(' ');
    final String fistName = nameParts.first;
    final String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';

    final response = await _dio.post(
      ApiConstant.REGISTER_ENDPOINT,
      data: {
        'first_name': fistName,
        'last_name': lastName,
        'email': credentials.email,
        'password': credentials.password,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> logout(String fcmToken) async {
    final response = await _dio.delete(
     '${ ApiConstant.USER_INFO_ENDPOINT}/logout',
      data: {
        'fcm_token': fcmToken
      },
    );

    return response.data as Map<String, dynamic>;
  }
}
