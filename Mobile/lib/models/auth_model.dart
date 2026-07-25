/// Auth usecases
library;

import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/schemas/auth_credentials.dart';
import 'package:gaspika_mobile/services/api/auth_service.dart';
import 'package:gaspika_mobile/services/notification_service.dart';
import 'package:gaspika_mobile/services/secure_storage_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthModel {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  Future<ApiResponse<dynamic>> login(LoginCredentials credentials) async {
    try {
      // register the device for push notification and get the FCM token
      final fcmToken = await _notificationService.getFCMToken();

      final loginResponse = await _authService.login(
        credentials.copyWith(fcmToken: fcmToken),
      );

      if (loginResponse.isEmpty) {
        return ApiResponse(
          hasError: true,
          message:
              'Réponse invalide du serveur. Veuillez réessayer plus tard.',
        );
      }

      //store the token
      if (loginResponse.containsKey('access_token')) {
        SecureStorageService.write(
          'access_token',
          loginResponse['access_token'],
        );
      }

      // store fcm_token
      SecureStorageService.write('fcm_token', fcmToken);

      return ApiResponse(data: loginResponse);
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while logging in: ${err.response?.statusCode} - ${err.message}',
      );

      // handle incorrect crendentials
      if (err.response?.statusCode == 401) {
        return ApiResponse(
          hasError: true,
          message: 'Email ou mot de passe incorrect.',
          errorType: NetworkErrorType.conflict,
        );
      }

      if (err.response?.statusCode == 422) {
        return ApiResponse(
          hasError: true,
          message:
              err.response?.data['message'] ??
              'Données de connexion invalides.',
        );
      }

      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while logging in: $err');
      return ApiResponse(
        hasError: true,
        message:
            'Impossible de se connecter à votre compte. Veuillez réessayer.',
      );
    }
  }

  Future<ApiResponse<dynamic>> register(SignupCredentials credentials) async {
    try {
      await _authService.register(credentials);

      return ApiResponse(
        message: 'Inscription réussie ! Veuillez vous connecter aprés.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while registering: ${err.response?.statusCode} - ${err.message}',
      );

      // Handle user already exist
      if (err.response?.statusCode == 409) {
        return ApiResponse(
          hasError: true,
          message: 'Cet email est déjà utilisé.',
        );
      }

      if (err.response?.statusCode == 422) {
        return ApiResponse(
          hasError: true,
          message:
              err.response?.data['message'] ??
              'Données d\'inscription invalides.',
        );
      }

      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while registering: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de créer votre compte. Veuillez réessayer.',
      );
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await SecureStorageService.read('access_token');

    if (token != null) {
      if (JwtDecoder.isExpired(token)) {
        await SecureStorageService.delete('access_token');
        return false;
      }
    }

    return token != null;
  }

  Future logout() async {
    String? fcmToken = await SecureStorageService.read('fcm_token');

    if (fcmToken != null) {
      // always clear the local session, even if the device is already gone
      try {
        await _authService.logout(fcmToken);
      } catch (err) {
        AppLogger.logger.e('Error while logging out the device: $err');
      }

      await SecureStorageService.delete('fcm_token');
    }

    await SecureStorageService.delete('access_token');
  }
}
