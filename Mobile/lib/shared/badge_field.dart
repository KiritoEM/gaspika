import 'package:flutter/cupertino.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class BadgeField extends StatelessWidget {
  final String label;
  final String value;

  const BadgeField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: .start,
      children: [
        Text(label),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(88, 208, 222, 126),
            border: BoxBorder.all(color: AppColors.secondary),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
