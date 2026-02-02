import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';

class ShoppingListStatusFilter extends StatelessWidget {
  final ShoppingListStatus selectedStatus;
  final List<Map<String, dynamic>> statusList;
  final Function(ShoppingListStatus) onSelect;

  const ShoppingListStatusFilter({
    super.key,
    required this.statusList,
    required this.selectedStatus,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statusList.map((status) {
        final isSelected = selectedStatus == status['value'];

        return ChoiceChip(
          label: Text(
            status['label'],
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.foreground,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          checkmarkColor: Colors.white,
          onSelected: (_) => onSelect(status['value'] as ShoppingListStatus),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.transparent, width: 0),
          ),
        );
      }).toList(),
    );
  }
}
