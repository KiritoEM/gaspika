import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int activeIndex;
  final Color? color;
  final int length;

  const CustomProgressIndicator({
    super.key,
    required this.activeIndex,
    this.length = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(23, 4, 23, 12),
      child: Row(
        children: List.generate(length, (index) {
          bool isActive = activeIndex == index;

          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: index < length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isActive ? progressColor : Colors.grey[300],
              ),
            ),
          );
        }),
      ),
    );
  }
}
