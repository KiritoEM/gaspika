import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String listName;
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({
    super.key,
    required this.listName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Supprimer la liste',
        style: TextStyle(fontWeight: .bold),
      ),
      content: Text(
        'Voulez-vous vraiment supprimer la liste "$listName" ?',
        style: TextStyle(color: AppColors.mutedForeground),
      ),
      backgroundColor: Colors.white,

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
