import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/domains-object/notification_preference.dart';
import 'package:gaspika_mobile/models/domains-object/user.dart';
import 'package:gaspika_mobile/models/schemas/change_password_schema.dart';
import 'package:gaspika_mobile/models/schemas/notification_preference_schema.dart';
import 'package:gaspika_mobile/models/schemas/update_user_schema.dart';
import 'package:gaspika_mobile/services/api/user_service.dart';
import 'package:gaspika_mobile/services/secure_storage_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';

class UserModel {
  final UserService _userService = UserService();

  Future<ApiResponse<User>> getUserInfo() async {
    try {
      final userResponse = await _userService.getUserInfo();

      return ApiResponse(
        data: User.fromJson(userResponse),
        message: 'Utilisateur récupéré avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while fetching user: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
       errorType: NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching user: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récuperer l\'utilisateur.',
      );
    }
  }

  Future<ApiResponse<User>> updateUserInfo(UpdateUserSchema newData) async {
    try {
      final userResponse = await _userService.updateUserInfo(newData);

      return ApiResponse(
        data: User.fromJson(userResponse),
        message: 'Informations modifiées avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while updating user: ${err.response?.statusCode} - ${err.message}',
      );

      // handle email already used
      if (err.response?.statusCode == 409) {
        return ApiResponse(
          hasError: true,
          message: 'Cet email est déjà utilisé.',
          errorType: NetworkErrorType.conflict,
        );
      }

      if (err.response?.statusCode == 422) {
        return ApiResponse(
          hasError: true,
          message: err.response?.data['message'] ?? 'Données invalides.',
        );
      }

      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while updating user: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de modifier vos informations. Veuillez réessayer.',
      );
    }
  }

  Future<ApiResponse<dynamic>> changePassword(
    ChangePasswordSchema newData,
  ) async {
    try {
      await _userService.changePassword(newData);

      return ApiResponse(message: 'Mot de passe modifié avec succès.');
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while changing password: ${err.response?.statusCode} - ${err.message}',
      );

      // handle incorrect current password
      if (err.response?.statusCode == 401) {
        return ApiResponse(
          hasError: true,
          message: 'Mot de passe actuel incorrect.',
          errorType: NetworkErrorType.unauthorized,
        );
      }

      // handle identical password
      if (err.response?.statusCode == 400) {
        return ApiResponse(
          hasError: true,
          message:
              'Le nouveau mot de passe doit être différent de l\'ancien.',
          errorType: NetworkErrorType.badRequest,
        );
      }

      if (err.response?.statusCode == 422) {
        return ApiResponse(
          hasError: true,
          message:
              err.response?.data['message'] ??
              'Le mot de passe doit contenir au moins 8 caractères.',
        );
      }

      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while changing password: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de modifier votre mot de passe. Veuillez réessayer.',
      );
    }
  }

  Future<ApiResponse<NotificationPreference>>
  getNotificationPreferences() async {
    try {
      final preferencesResponse = await _userService
          .getNotificationPreferences();

      return ApiResponse(
        data: NotificationPreference.fromJson(preferencesResponse),
        message: 'Préférences récupérées avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while fetching notification preferences: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching notification preferences: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récuperer vos préférences de notification.',
      );
    }
  }

  Future<ApiResponse<NotificationPreference>> updateNotificationPreferences(
    NotificationPreferenceSchema newData,
  ) async {
    try {
      final preferencesResponse = await _userService
          .updateNotificationPreferences(newData);

      return ApiResponse(
        data: NotificationPreference.fromJson(preferencesResponse),
        message: 'Préférences modifiées avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while updating notification preferences: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while updating notification preferences: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de modifier vos préférences. Veuillez réessayer.',
      );
    }
  }

  Future<ApiResponse<dynamic>> deleteAccount(String password) async {
    try {
      final fcmToken = await SecureStorageService.read('fcm_token');

      await _userService.deleteAccount(password, fcmToken);

      // clear the local session
      await SecureStorageService.delete('fcm_token');
      await SecureStorageService.delete('access_token');

      return ApiResponse(message: 'Compte supprimé avec succès.');
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while deleting account: ${err.response?.statusCode} - ${err.message}',
      );

      // handle incorrect password
      if (err.response?.statusCode == 401) {
        return ApiResponse(
          hasError: true,
          message: 'Mot de passe incorrect.',
          errorType: NetworkErrorType.unauthorized,
        );
      }

      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while deleting account: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de supprimer votre compte. Veuillez réessayer.',
      );
    }
  }
}
