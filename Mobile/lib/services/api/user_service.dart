import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';

class UserService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await _dio.get('${ApiConstant.USER_INFO_ENDPOINT}/me');

    return response.data['data'];
  }
}
