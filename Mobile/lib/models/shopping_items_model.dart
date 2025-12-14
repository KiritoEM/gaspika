import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
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
        data: jsonDecode(response['count'].toString()) as int,
        message: 'Données récupérées avec succès.',
      );
    } on DioException catch (err) {
      throw NetworkErrorHandler.handleError(err).isNotEmpty
          ? NetworkErrorHandler.handleError(err)
          : err;
    } catch (err) {
      AppLogger.logger.e('Error while fetching avalaible food: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récuperer le nombre de produits disponibles.',
      );
    }
  }

  // 🔥 NOUVEAU
  Future<ApiResponse<List<ShoppingListItem>>> getShoppingWeekItems() async {
    try {
      final response = await _shoppingService.getShoppingWeekItems();

      await Future.delayed(const Duration(seconds: 2));

      final items = response
          .map((e) => ShoppingListItem.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse(
        data: items,
        message: 'Produits de la semaine récupérés.',
      );
    } on DioException catch (err) {
      throw NetworkErrorHandler.handleError(err).isNotEmpty
          ? NetworkErrorHandler.handleError(err)
          : err;
    } catch (err) {
      AppLogger.logger.e('Error while fetching shopping week items: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récupérer les produits de la semaine.',
      );
    }
  }
}
