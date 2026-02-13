import 'package:gaspika_mobile/constants/enums/enums.dart';

class ShoppingListUtils {
  static String convertPeriodFilterToBackendEnum(PeriodFilterEnum period) {
    switch (period) {
      case PeriodFilterEnum.currentMonth:
        return 'CURRENT_MONTH';
      case PeriodFilterEnum.currentYear:
        return 'CURRENT_YEAR';
      case PeriodFilterEnum.last5Month:
        return 'LAST_5_MONTH';
      case PeriodFilterEnum.lastYear:
        return 'LAST_YEAR';
    }
  }
}
