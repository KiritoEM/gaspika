import 'package:dio/dio.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/services/api/shopping_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';

class ShoppingListModel {
  final ShoppingService _shoppingService = ShoppingService();

  Future<ApiResponse<List<ShoppingList>>> getShoppingList() async {
    try {
      final response = await _shoppingService.getShoppingList();

      await Future.delayed(const Duration(seconds: 2));

      final items = response
          .map((e) => ShoppingList.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse(
        data: items,
        message: 'Données récupérées avec succès.',
      );
    } on DioException catch (err) {
      throw NetworkErrorHandler.handleError(err).isNotEmpty
          ? NetworkErrorHandler.handleError(err)
          : err;
    } catch (err) {
      AppLogger.logger.e('Error while fetching shopping list: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récuperer la liste de courses.',
      );
    }
  }
}
