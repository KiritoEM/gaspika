import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/services/api/shopping_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';

class ShoppingListModel {
  final ShoppingService _shoppingService = ShoppingService();

  Future<ApiResponse<List<ShoppingList>>> getShoppingList(
    ShoppingListStatus statusFilter,
  ) async {
    try {
      final response = await _shoppingService.getShoppingList(
        statusFilter != ShoppingListStatus.all
            ? statusFilter.name.toUpperCase()
            : null,
      );

      await Future.delayed(const Duration(seconds: 2));

      final items = response
          .map((e) => ShoppingList.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse(
        data: items,
        message: 'Listes de courses récupérées avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while fetching shopping list: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching shopping list: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récupérer les listes de courses.',
      );
    }
  }

  Future<ApiResponse<String>> generateShoppingList(int weekNumber) async {
    try {
      await _shoppingService.generateShoppingList(weekNumber);

      await Future.delayed(const Duration(seconds: 2));

      return ApiResponse(
        data: 'success',
        message: 'Liste de courses générée avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while generating shopping list: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while generating shopping list: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de générer la liste de courses.',
      );
    }
  }

  Future<ApiResponse<String>> deteleShoppingList(int listId) async {
    try {
      await _shoppingService.deleteShoppingList(listId);

      return ApiResponse(
        data: 'success',
        message: 'Liste de courses supprimée avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while generating shopping list: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while deleting shopping list: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de supprimer la liste de courses.',
      );
    }
  }
}
