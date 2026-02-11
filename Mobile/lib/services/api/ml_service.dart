import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/models/schemas/createItem.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/unit_utils.dart';

class MlService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> predictQuantity(
    CreateShoppingItemSchema data,
  ) async {
    AppLogger.logger.i({
      'food': data.foodName,
      'nombre_personnes': data.personNumber,
      'unite': UnitUtils.convertUnitToBackend(data.unit),
      'duree_jours': 7,
      'type_repas': 'dejeuner',
      'categorie': data.backendCategory,
    });

    final response = await _dio.post(
      ApiConstant.PREDICT_QUANTITY,
      data: {
        'food': data.foodName,
        'nombre_personnes': data.personNumber,
        'unite': UnitUtils.convertUnitToBackend(data.unit),
        'duree_jours': 7,
        'type_repas': 'dejeuner',
        'categorie': data.backendCategory,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> predictConservationDuration(
    CreateShoppingItemSchema data,
  ) async {
    final response = await _dio.post(
      ApiConstant.PREDICT_CONSERVATION,
      data: {
        'humidite_relative': data.humidity,
        'categorie': data.backendCategory,
      },
    );

    return response.data as Map<String, dynamic>;
  }
}
