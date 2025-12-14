import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';

class DioConfig {
  static Dio? _dio;
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static Dio get instance {
    _dio ??= _createDio();

    return _dio!;
  }

  static Dio? _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: ApiConstant.CONNECT_TIMEOUT,
        receiveTimeout: ApiConstant.RECEIVE_TIMEOUT,
        responseType: ResponseType.json,
        headers: ApiConstant.HEADERS,
      ),
    );

    return dio;
  }

  // Reset
  static void reset() {
    _dio = null;
  }
}
