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

  static String? getDatesInterval(DateTime date) {
    var diff = DateTime.now().difference(date);

    if (diff.inDays >= 1) {
      return 'il y a ${diff.inDays} jour${diff.inDays == 1 ? '' : 's'}';
    }

    if (diff.inHours >= 1) {
      return 'il y a ${diff.inHours} heure${diff.inHours == 1 ? '' : 's'}';
    }

    if (diff.inMinutes >= 1) {
      return 'il y a ${diff.inDays} minute${diff.inDays == 1 ? '' : 's'}';
    }

     if (diff.inSeconds >= 1) {
      return 'il y a ${diff.inSeconds} seconde${diff.inSeconds == 1 ? '' : 's'}';
    }

    return null;
  }
}
