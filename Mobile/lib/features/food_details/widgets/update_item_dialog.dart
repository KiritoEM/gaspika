// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaspika_mobile/features/food_details/viewmodels/food_details_viewmodel.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:gaspika_mobile/utils/unit_utils.dart';
import 'package:provider/provider.dart';

class UpdateItemDialog extends StatefulWidget {
  final VoidCallback onUpdate;

  const UpdateItemDialog({super.key, required this.onUpdate});

  @override
  State<UpdateItemDialog> createState() => _UpdateItemDialogState();
}

class _UpdateItemDialogState extends State<UpdateItemDialog> {
  late FoodDetailsViewmodel _foodDetailsVm;

  @override
  void initState() {
    super.initState();

    _foodDetailsVm = Provider.of<FoodDetailsViewmodel>(context, listen: false);
    _foodDetailsVm.itemNameController.text =
        _foodDetailsVm.currentItem!.foodName;
    _foodDetailsVm.priceController.text = _foodDetailsVm.currentItem!.price
        .toString();
    _foodDetailsVm.quantityController.text = _foodDetailsVm
        .currentItem!
        .recommendedQuantity
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.white,
      title: Text(
        'Modifier l\'aliment',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBlock(
              label: 'Nom de l\'aliment',
              child: TextField(
                controller: _foodDetailsVm.itemNameController,
                decoration: InputDecoration(hintText: 'Entrez un nouveau nom'),
                autofocus: true,
              ),
            ),

            const SizedBox(height: 24),

            FormBlock(
              label: 'Prix(en Ariary)',
              child: TextField(
                controller: _foodDetailsVm.priceController,
                decoration: InputDecoration(hintText: 'ex: 2000'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),

            const SizedBox(height: 24),

            FormBlock(
              label:
                  'Quantité (en ${UnitUtils.getQuantityUnitText(_foodDetailsVm.currentItem!.quantityUnit)})',
              child: TextField(
                controller: _foodDetailsVm.quantityController,
                decoration: InputDecoration(hintText: 'ex: 4'),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              child: Consumer<FoodDetailsViewmodel>(
                builder: (context, vm, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    onPressed:
                        (vm.itemNameController.text.isEmpty ||
                            vm.priceController.text.isEmpty ||
                            vm.quantityController.text.isEmpty)
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
