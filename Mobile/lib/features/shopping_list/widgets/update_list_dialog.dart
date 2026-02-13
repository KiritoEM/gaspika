import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/shopping_list/viewmodels/shopping_list_viewmodel.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:provider/provider.dart';

class UpdateListDialog extends StatelessWidget {
  final String listName;
  final VoidCallback onUpdate;

  const UpdateListDialog({
    super.key,
    required this.listName,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final shoppingListVm = Provider.of<ShoppingListViewModel>(
      context,
      listen: false,
    );

    // initialize value of textController with current listName
    shoppingListVm.listNameController.text = listName;

    return AlertDialog(
      title: const Text(
        'Modifier la liste',
        style: TextStyle(fontWeight: .bold),
      ),

      content: Column(
        mainAxisSize: .min,
        children: [
          FormBlock(
            label: 'Nouveau nom de la liste',
            child: TextField(
              controller: shoppingListVm.listNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Entrez un nouveau nom',
              ),
              autofocus: true,
            ),
          ),
        ],
      ),

      backgroundColor: Colors.white,

      actions: [
        Container(
          margin: EdgeInsets.only(top: 8),
          child: Row(
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
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: shoppingListVm.listNameController.text.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          onUpdate();
                        },
                  child: const Text('Modifier'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
