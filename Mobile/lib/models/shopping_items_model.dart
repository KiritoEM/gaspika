import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/models/schemas/createItem.dart';
import 'package:gaspika_mobile/services/api/shopping_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';

class ShoppingItemsModel {
  final ShoppingService _shoppingService = ShoppingService();

  Future<ApiResponse<int?>> getAvalaibleFoodCount() async {
    try {
      final response = await _shoppingService.getAvalaibleFoodCount();

      await Future.delayed(const Duration(seconds: 2));

      return ApiResponse(
        data: response['count'] as int,
        message: 'Aliments récupérées avec succès.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while fetching available food: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching avalaible food: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récuperer le nombre d\'aliments disponibles.',
      );
    }
  }

  Future<ApiResponse<List<ShoppingListItem>>> getShoppingWeekItems() async {
    try {
      final response = await _shoppingService.getShoppingWeekItems();

      await Future.delayed(const Duration(seconds: 2));

      final items = response
          .map((e) => ShoppingListItem.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse(
        data: items,
        message: 'Aliments de la semaine récupérés.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while fetching shopping week items: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching shopping week items: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récupérer les aliments de la semaine.',
      );
    }
  }

  Future<ApiResponse<List<ShoppingListItem>>> getShoppingItems(
    int listId,
  ) async {
    try {
      final response = await _shoppingService.getShoppingItemsById(listId);

      final items = response
          .map((e) => ShoppingListItem.fromJson(e as Map<String, dynamic>))
          .toList();

      await Future.delayed(const Duration(seconds: 2));

      return ApiResponse(data: items, message: 'Aliments recuperés.');
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while fetching shopping items: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching shopping items: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récupérer les aliments.',
      );
    }
  }

  Future<ApiResponse<List<ShoppingListItem>>> createShoppingItem(
    CreateShoppingItemSchema item,
    int listId,
  ) async {
    try {
      await _shoppingService.createShoppingItem(item, listId);

      await Future.delayed(const Duration(seconds: 2));

      return ApiResponse(message: 'Aliment ajouté.');
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while creating shopping item: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while creating shopping item: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de créer l\'aliment.',
      );
    }
  }

  Future<ApiResponse<ShoppingListItem>> getShoppingItemById(int itemId) async {
    try {
      final response = await _shoppingService.getShoppingItemById(itemId);

      final item = ShoppingListItem.fromJson(response);

      await Future.delayed(const Duration(seconds: 2));

      return ApiResponse(data: item, message: 'Aliments recuperé avec succés.');
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while fetching shopping item: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching shopping item: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récupérer l\'aliment.',
      );
    }
  }

  Future<ApiResponse<ShoppingListItem>> markAsComplete(int itemId) async {
    try {
      final response = await _shoppingService.markItemAsComplete(itemId);

      final item = ShoppingListItem.fromJson(response);

      await Future.delayed(const Duration(seconds: 2));

      return ApiResponse(data: item, message: 'Aliments marqué comme acheté.');
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while marking shopping item: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while marking shopping item: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de marquer l\'aliment comme acheté.',
      );
    }
  }
}
