import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class BottomsheetAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const BottomsheetAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color actionColor = isDestructive
        ? Colors.red
        : AppColors.mutedForeground;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        child: Row(
          children: [
            Icon(icon, color: actionColor, size: 20),

            const SizedBox(width: 12),

            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
