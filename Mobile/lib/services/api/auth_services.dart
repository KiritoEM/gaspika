import 'package:dio/dio.dart';
import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/models/schemas/login_credentials.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';

class AuthServices {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> login(LoginCredentials credentials) async {
    try {
      final response = await _dio.post(ApiConstant.)
    } 
    on DioException catch (err) {
      throw NetworkErrorHandler.handleError(err);
    }
    ;
  }
}
