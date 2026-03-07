import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';

class CategoriesService {
  final _dio = DioConfig.instance;

  Future<List<dynamic>> getAllCategories() async {
    final response = await _dio.get(ApiConstant.CATEGORIES_ENDPOINT);

    return response.data['data'] as List<dynamic>;
  }
}
