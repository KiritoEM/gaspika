import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double value;
  final Color? color;

  const CustomProgressIndicator({super.key, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;

    return LinearProgressIndicator(
      value: value,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
        0.3,
      ),
      color: progressColor,
      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      minHeight: 4,
    );
  }
}
