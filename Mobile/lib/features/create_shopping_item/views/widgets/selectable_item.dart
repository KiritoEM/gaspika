import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class SelectableItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final Function onSelect;

  const SelectableItem({
    super.key,
    required this.label,
    required this.onSelect,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          borderOnForeground: false,
          elevation: 0,
          color: isActive
              ? const Color.fromARGB(30, 245, 200, 87)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isActive ? AppColors.primary : Colors.grey[300]!,
              width: isActive ? 2.0 : 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.foreground,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
