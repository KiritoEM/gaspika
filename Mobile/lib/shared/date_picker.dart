import 'package:flutter/material.dart';
import 'package:gaspika_mobile/utils/date.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onSelectDate;

  const DatePicker({super.key, required this.onSelectDate, this.value});

  Future _handlePickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final startOfCurrentWeek = DateUtilities.startOfWeek(now);

    bool isPastWeek(DateTime date) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      return normalizedDate.isBefore(startOfCurrentWeek);
    }

    DateTime initialDate = value ?? now;
    if (isPastWeek(initialDate)) {
      initialDate = now;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startOfCurrentWeek,
      lastDate: DateTime(now.year, now.month, now.day + 13), // 2 semaines
      locale: const Locale('fr'),
      selectableDayPredicate: (date) {
        final result = !isPastWeek(date);
        return result;
      },
    );

    if (picked != null) {
      onSelectDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.calendar_today, size: 20),
      ),
      controller: TextEditingController(
        text: value != null ? DateFormat('dd/MM/yyyy').format(value!) : '',
      ),
      onTap: () {
        _handlePickDate(context);
      },
    );
  }
}
