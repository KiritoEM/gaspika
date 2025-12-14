/// Auth usecases
library;

import 'package:dio/dio.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/schemas/auth_credentials.dart';
import 'package:gaspika_mobile/services/api/auth_service.dart';
import 'package:gaspika_mobile/services/secure_storage_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthModel {
  final AuthService _authService = AuthService();
  // Login
  Future<ApiResponse<dynamic>> login(LoginCredentials credentials) async {
    try {
      final loginResponse = await _authService.login(credentials);

      if (loginResponse.isEmpty) {
        return ApiResponse(
          hasError: true,
          message:
              'Réponse invalide du serveur. Veillez réessayer plus tard.',
        );
      }

      //store the token
      if (loginResponse.containsKey('access_token')) {
        SecureStorageService.write(
          'access_token',
          loginResponse['access_token'],
        );
      }

      return ApiResponse(data: loginResponse);
    } on DioException catch (err) {
      if (err.type == DioExceptionType.badResponse) {
        if (err.response?.statusCode == 401) {
          return ApiResponse(
            hasError: true,
            message: 'Email ou mot de passe incorrect. Veuillez réessayer.',
          );
        }
      }

      throw NetworkErrorHandler.handleError(err).isNotEmpty
          ? NetworkErrorHandler.handleError(err)
          : err;
    } catch (err) {
      AppLogger.logger.e('Error while logging in: $err');
      return ApiResponse(
        hasError: true,
        message:
            'Impossible de se connecter à votre compte. Veuillez réessayer.',
      );
    }
  }

  /// Register
  Future<ApiResponse<dynamic>> register(SignupCredentials credentials) async {
    try {
      await _authService.register(credentials);

      return ApiResponse(
        message: 'Inscription réussie ! Veuillez vous connecter aprés.',
      );
    } on DioException catch (err) {
      throw NetworkErrorHandler.handleError(err).isNotEmpty
          ? NetworkErrorHandler.handleError(err)
          : err;
    } catch (err) {
      AppLogger.logger.e('Error while registering: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de créer votre compte. Veuillez réessayer.',
      );
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await SecureStorageService.read('access_token');
    AppLogger.logger.i('Auth token: $token');

    if (token != null) {
      if (JwtDecoder.isExpired(token)) {
        await SecureStorageService.delete('access_token');
        return false;
      }
    }

    return token != null;
  }
}
