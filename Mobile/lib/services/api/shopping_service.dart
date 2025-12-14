import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/utils/date.dart';

class ShoppingService {
  final _dio = DioConfig.instance;

  Future<int> getAvalaibleFoodCount() async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/${DateUtils.getCurrentWeekNumberISO()}/available-products-count',
    );
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getShoppingWeekItems() async {
    final response = await _dio.get(
      '${ApiConstant.SHOPPING_ITEMS_ENDPOINT}/${DateUtils.getCurrentWeekNumberISO()}/shopping-week',
    );
    return response.data;
  }
}
