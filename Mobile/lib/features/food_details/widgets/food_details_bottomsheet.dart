import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/features/food_details/viewmodels/food_details_viewmodel.dart';
import 'package:gaspika_mobile/shared/app_bottomsheet.dart';
import 'package:gaspika_mobile/shared/bottomsheet_action.dart';

import 'delete_confirmation_dialog.dart';

class FoodDetailsBottomsheet {
  static Future show(
    BuildContext context,
    FoodDetailsViewmodel foodDetailsVm,
    VoidCallback onDelete,
  ) async {
    return await AppBottomSheet.show(
      context: context,
      builder: (context, setModalState) {
        return [
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              const SizedBox(height: 8),

              BottomsheetAction(
                label: 'Modifier',
                icon: SvgPicture.asset('assets/icons/edit.svg', width: 18),
                onTap: () => {},
              ),

              const SizedBox(height: 16),

              // const SizedBox(height: 16),
              BottomsheetAction(
                label: 'Supprimer',
                icon: SvgPicture.asset('assets/icons/trash.svg', width: 20),
                isDestructive: true,
                onTap: () => _showDeleteConfirmationDialog(
                  context,
                  foodDetailsVm.currentItem?.foodName ?? "",
                  () => onDelete(),
                ),
              ),
            ],
          ),
        ];
      },
    );
  }

  static void _showDeleteConfirmationDialog(
    BuildContext context,
    String name,
    Function() onDelete,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          DeleteConfirmationDialog(foodName: name, onDelete: () => onDelete()),
    );
  }
}
