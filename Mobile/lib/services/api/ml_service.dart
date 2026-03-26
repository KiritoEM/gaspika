import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/models/schemas/create_item_schema.dart';
import 'package:gaspika_mobile/utils/unit_utils.dart';

class MlService {
  final _dio = DioConfig.instance;

  Future<Map<String, dynamic>> predictQuantity(
    CreateShoppingItemSchema data,
  ) async {
    final response = await _dio.post(
      ApiConstant.PREDICT_QUANTITY,
      data: {
        'food': data.foodName,
        'nombre_personnes': data.personNumber,
        'unite': UnitUtils.convertUnitToBackend(data.unit),
        'duree_jours': data.consumptionDuration,
        'type_repas': data.mealFrequency,
        'categorie': data.category?.mlCategory,
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
        'categorie': data.category?.mlCategory,
      },
    );

    return response.data as Map<String, dynamic>;
  }
}
