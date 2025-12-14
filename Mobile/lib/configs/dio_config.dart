import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/services/secure_storage_service.dart';

class DioConfig {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  // Singleton
  static final DioConfig _instance = DioConfig._internal();
  factory DioConfig() => _instance;
  DioConfig._internal();

  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: ApiConstant.CONNECT_TIMEOUT,
        receiveTimeout: ApiConstant.RECEIVE_TIMEOUT,
        sendTimeout: ApiConstant.SEND_TIMEOUT,
        responseType: ResponseType.json,
        headers: ApiConstant.HEADERS,
      ),
    );

    //  Request Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.read('access_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
      ),
    );

    return dio;
  }

  // Reset
  static void reset() {
    _dio = null;
  }
}
