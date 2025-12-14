/// Auth usecases
library;

import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/schemas/login_credentials.dart';
import 'package:gaspika_mobile/services/api/auth_service.dart';
import 'package:gaspika_mobile/services/secure_storage_service.dart';

class AuthModel {
  final AuthService _authService = AuthService();

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

      return ApiResponse(data: loginResponse, hasError: false);
    } catch (err) {
      return ApiResponse(
        hasError: true,
        message:
            'Impossible de se connecter à votre compte. Veillez réessayer plus tard.',
      );
    }
  }
}
