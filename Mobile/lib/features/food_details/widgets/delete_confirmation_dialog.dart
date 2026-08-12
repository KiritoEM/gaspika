import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String foodName;
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({
    super.key,
    required this.foodName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.white,
      title: const Text(
        'Supprimer l\'aliment',
        style: TextStyle(fontWeight: .bold),
      ),
      content: Text(
        'Voulez-vous vraiment supprimer l\'aliment "$foodName" ?',
        style: TextStyle(color: AppColors.mutedForeground),
      ),

      actions: [
        Row(
          spacing: 8,

          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mutedForeground,
                ),
                child: const Text('Annuler'),
              ),
            ),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  onDelete();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.destructive,
                ),
                child: const Text('Supprimer'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
