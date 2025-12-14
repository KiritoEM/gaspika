import 'package:intl/intl.dart';

class DateUtils {
  static int getCurrentWeekNumberISO() {
    final now = DateTime.now();
    return int.parse(DateFormat('w').format(now));
  }
}
