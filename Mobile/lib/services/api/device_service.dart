import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';

class DeviceService {
  final _dio = DioConfig.instance;

  Future updateFcmToken(String fcmToken, String newFcmToken) async {
    await _dio.patch(
      ApiConstant.DEVICE_ENDPOINT,
      data: {'fcm_token': fcmToken, 'new_fcm_token': newFcmToken},
    );
  }
}
