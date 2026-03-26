import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/features/food_details/viewmodels/food_details_viewmodel.dart';
import 'package:gaspika_mobile/features/food_details/widgets/update_item_dialog.dart';
import 'package:gaspika_mobile/shared/app_bottomsheet.dart';
import 'package:gaspika_mobile/shared/bottomsheet_action.dart';
import 'package:provider/provider.dart';
import 'delete_confirmation_dialog.dart';

class FoodDetailsBottomsheet {
  static Future show({
    required BuildContext context,
    required bool isAvailable,
    required VoidCallback onUpdate,
    required VoidCallback onDelete,
  }) async {
    return await AppBottomSheet.show(
      context: context,
      builder: (context, setModalState) {
        return [
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              const SizedBox(height: 8),
              if (isAvailable)
                BottomsheetAction(
                  label: 'Modifier',
                  icon: SvgPicture.asset('assets/icons/edit.svg', width: 18),
                  onTap: () => _showEditDialog(context, () => onUpdate()),
                ),

              if (isAvailable) const SizedBox(height: 16),

              BottomsheetAction(
                label: 'Supprimer',
                icon: SvgPicture.asset('assets/icons/trash.svg', width: 20),
                isDestructive: true,
                onTap: () =>
                    _showDeleteConfirmationDialog(context, () => onDelete()),
              ),
            ],
          ),
        ];
      },
    );
  }

  static void _showEditDialog(BuildContext context, Function() onUpdate) {
    showDialog(
      context: context,
      builder: (dialogContext) => UpdateItemDialog(onUpdate: () => onUpdate()),
    );
  }

  static void _showDeleteConfirmationDialog(
    BuildContext context,
    Function() onDelete,
  ) {
    final foodDetailsVm = Provider.of<FoodDetailsViewmodel>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteConfirmationDialog(
        foodName: foodDetailsVm.currentItem!.foodName,
        onDelete: () => onDelete(),
      ),
    );
  }
}
