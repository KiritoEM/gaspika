import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/domains-object/user.dart';
import 'package:gaspika_mobile/services/api/user_service.dart';
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
}
