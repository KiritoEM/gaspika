import 'package:week_number/iso.dart';

class DateUtilities {
  static int getCurrentWeekNumberISO({DateTime? date}) {
    return (date ?? DateTime.now()).weekNumber;
  }

  static DateTime startOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }
}
