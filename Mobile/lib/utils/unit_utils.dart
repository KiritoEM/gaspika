import 'package:gaspika_mobile/constants/enums/enums.dart';

class UnitUtils {
  static String getQuantityUnitText(QuantityUnit unit) {
    switch (unit) {
      case QuantityUnit.kilogram:
        return 'kg';
      case QuantityUnit.liter:
        return 'L';
      case QuantityUnit.gram:
        return 'g';
      case QuantityUnit.milliliter:
        return 'ml';
      case QuantityUnit.unit:
        return 'pcs';
    }
  }

    static String convertUnitToBackend(QuantityUnit unit) {
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
}
