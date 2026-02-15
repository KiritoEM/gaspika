import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/schemas/createItem.dart';
import 'package:gaspika_mobile/services/api/ml_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';

class MlModel {
  final MlService _mlService = MlService();

  Future<ApiResponse<Map<String, dynamic>>> predictQuantity(
    CreateShoppingItemSchema data,
  ) async {
    try {
      final response = await _mlService.predictQuantity(data);

      return ApiResponse(
        data: response,
        message: 'Quantité prédite avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while predicting quantity: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while predicting quantity: $err');
      return ApiResponse(
        hasError: true,
        message:
            'Une erreur s\'est produite lors de la prédiction de la quantité.',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> predictConservationDuration(
    CreateShoppingItemSchema data,
  ) async {
    try {
      final response = await _mlService.predictConservationDuration(data);

      return ApiResponse(
        data: response,
        message: 'Durée de conservation prédite avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while predicting conservation duration: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while predicting conservation duration: $err');
      return ApiResponse(
        hasError: true,
        message:
            'Une erreur s\'est produite lors de la prédiction de la durée de conservation.',
      );
    }
  }
}
