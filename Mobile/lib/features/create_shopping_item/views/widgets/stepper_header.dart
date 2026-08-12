import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class StepperHeader extends StatelessWidget {
  final String title;
  final String description;

  const StepperHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize!,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(description, style: TextStyle(color: AppColors.mutedForeground)),
      ],
    );
  }
}
