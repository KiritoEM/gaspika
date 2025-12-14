import 'package:dio/dio.dart';

class NetworkErrorHandler {
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé';

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response);

      case DioExceptionType.cancel:
        return 'Requête annulée';

      default:
        return 'Erreur de connexion';
    }
  }

  static String _handleStatusCode(Response? response) {
    switch (response?.statusCode) {
      case 401:
        return 'Unauthorized, no access';
      case 403:
        return 'Access forbidden';
      case 500:
        return 'Server error, please try again later';
      default:
        return response?.data['message'] ?? 'Une erreur est survenue';
    }
  }
}
