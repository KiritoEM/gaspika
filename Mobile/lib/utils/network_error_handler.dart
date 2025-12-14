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
      case 400:
        return response?.data['message'] ?? 'Requête invalide';
      case 401:
        return 'Non autorisé. Veuillez vous reconnecter';
      case 403:
        return 'Accès refusé';
      case 404:
        return 'Ressource introuvable';
      case 500:
        return 'Erreur serveur';
      default:
        return response?.data['message'] ?? 'Une erreur est survenue';
    }
  }
}
