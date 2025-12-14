import 'package:week_number/iso.dart';

class DateUtilities {
  static int getCurrentWeekNumberISO() {
    final now = DateTime.now();
    print(now.weekNumber);
    return now.weekNumber;
  }
}
