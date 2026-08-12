import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';

class NetworkErrorHandler {
  static Map<String, dynamic> handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return {
        'type': NetworkErrorType.network,
        'message': 'Oops ! Pas de connexion Internet. Vérifiez votre réseau.',
      };
    } else if (error.type == DioExceptionType.cancel) {
      return {'type': NetworkErrorType.canceled, 'message': 'Requête annulée.'};
    } else if (error.type == DioExceptionType.badResponse) {
      return _handleStatusCode(error.response);
    } else {
      return {
        'type': NetworkErrorType.unknown,
        'message': 'Oops ! Une erreur inattendue est survenue.',
      };
    }
  }

  static Map<String, dynamic> _handleStatusCode(Response? response) {
    switch (response?.statusCode) {
      case 401:
        return {
          'type': NetworkErrorType.unauthorized,
          'message': 'Votre session a expiré. Veuillez vous reconnecter.',
        };
      case 403:
        return {
          'type': NetworkErrorType.forbidden,
          'message': 'Désolé, accès refusé.',
        };
      case 404:
        return {
          'type': NetworkErrorType.notFound,
          'message': 'Oops ! Ressource introuvable.',
        };
      case 500:
        return {
          'type': NetworkErrorType.server,
          'message': 'Oops ! Erreur serveur. Réessayez plus tard.',
        };
      case 502:
      case 503:
        return {
          'type': NetworkErrorType.server,
          'message':
              'Service temporairement indisponible. Réessayez plus tard.',
        };
      default:
        return {
          'type': NetworkErrorType.unknown,
          'message': 'Oops ! Une erreur est survenue.  Veuillez réessayer.',
        };
    }
  }
}
