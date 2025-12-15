import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/utils/date.dart';

class ShoppingService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> getAvalaibleFoodCount() async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/${DateUtilities.getCurrentWeekNumberISO()}/available-products-count',
    );

    return response.data;
  }

  Future<List<dynamic>> getShoppingWeekItems() async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/${DateUtilities.getCurrentWeekNumberISO()}/shopping-week',
    );
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getShoppingList() async {
    final response = await _dio.get(ApiConstant.SHOPPING_LIST_ENDPOINT);
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> generateShoppingList(int weekNumber) async {
    final response = await _dio.post(
      ApiConstant.SHOPPING_LIST_GENERATE_ENDPOINT,
      queryParameters: {'week_number': weekNumber},
      data: [],
    );

    return response.data;
  }

  Future<List<dynamic>> getShoppingItemsById(int listId) async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/$listId',
    );
    return response.data as List<dynamic>;
  }
}
