import 'package:week_number/iso.dart';

class DateUtilities {
  static int getCurrentWeekNumberISO() {
    final now = DateTime.now();
    return now.weekNumber;
  }
}
