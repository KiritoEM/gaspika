import 'package:gaspika_mobile/configs/dio_config.dart';
import 'package:gaspika_mobile/constants/api_constant.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/schemas/createItem.dart';

class MlService {
  final _dio = DioConfig.instance;

  String _convertUnitToBackend(QuantityUnit unit) {
    switch (unit) {
      case QuantityUnit.kilogram:
      case QuantityUnit.gram:
        return 'kg';
      case QuantityUnit.liter:
      case QuantityUnit.milliliter:
        return 'l';
      case QuantityUnit.unit:
        return 'piece';
    }
  }

  Future<Map<String, dynamic>> predictQuantity(
    CreateShoppingItemSchema data,
  ) async {
    final response = await _dio.post(
      ApiConstant.PREDICT_QUANTITY,
      data: {
        'food': data.foodName,
        'nombre_personnes': data.personNumber,
        'unite': _convertUnitToBackend(data.unit),
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
