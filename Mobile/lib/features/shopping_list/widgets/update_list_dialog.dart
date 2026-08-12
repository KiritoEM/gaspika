import 'package:flutter/material.dart';
import 'package:gaspika_mobile/features/shopping_list/viewmodels/shopping_list_viewmodel.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:provider/provider.dart';

class UpdateListDialog extends StatefulWidget {
  final String listName;
  final VoidCallback onUpdate;

  const UpdateListDialog({
    super.key,
    required this.listName,
    required this.onUpdate,
  });

  @override
  State<UpdateListDialog> createState() => _UpdateListDialogState();
}

class _UpdateListDialogState extends State<UpdateListDialog> {
  late ShoppingListViewModel shoppingListVm;

  @override
  void initState() {
    super.initState();
    shoppingListVm = Provider.of<ShoppingListViewModel>(context, listen: false);
    shoppingListVm.listNameController.text = widget.listName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.white,
      title: Text(
        'Modifier la liste',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBlock(
              label: 'Nom de la liste',
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
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Annuler'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Consumer<ShoppingListViewModel>(
                builder: (context, vm, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    onPressed: vm.listNameController.text.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);
                            widget.onUpdate();
                          },
                    child: const Text('Modifier'),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
