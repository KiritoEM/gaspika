import 'package:dio/dio.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/api_response.dart';
import 'package:gaspika_mobile/models/domains-object/category.dart';
import 'package:gaspika_mobile/services/api/categories_service.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/network_error_handler.dart';

class CategoriesModel {
  final CategoriesService _categoriesService = CategoriesService();

  Future<ApiResponse<List<Category>>> getAllCategories() async {
    try {
      final response = await _categoriesService.getAllCategories();

      final categories = response
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse(
        data: categories,
        message: 'Toutes les catégories récupérées.',
      );
    } on DioException catch (err) {
      AppLogger.logger.e(
        'DioException while fetching all categories: ${err.response?.statusCode} - ${err.message}',
      );
      return ApiResponse(
        hasError: true,
        message: NetworkErrorHandler.handleError(err)['message'],
        errorType:
            NetworkErrorHandler.handleError(err)['type'] as NetworkErrorType,
      );
    } catch (err) {
      AppLogger.logger.e('Error while fetching all categories: $err');
      return ApiResponse(
        hasError: true,
        message: 'Impossible de récupérer toutes les catégories',
      );
    }
  }
}
