import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/shared/badge_field.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:gaspika_mobile/shared/upload_image.dart';
import 'package:gaspika_mobile/utils/unit_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class FinalizeShoppingItemForm extends StatefulWidget {
  final String listId;
  final String listName;
  final int weekNumber;

  const FinalizeShoppingItemForm({
    super.key,
    required this.listId,
    required this.listName,
    required this.weekNumber,
  });

  @override
  State<FinalizeShoppingItemForm> createState() =>
      _FinalizeShoppingItemFormState();
}

class _FinalizeShoppingItemFormState extends State<FinalizeShoppingItemForm> {
  @override
  Widget build(BuildContext context) {
    final createShoppingItemVm = Provider.of<CreateShoppingItemViewModel>(
      context,
    );

    Future _handleSubmit(
      BuildContext context,
      CreateShoppingItemViewModel createShoppingItemVm,
    ) async {
      if (context.mounted) {
        context.go(NavigationConstant.SHOPPING_LISTS_ROUTE);
      }

      createShoppingItemVm
          .createAliment(int.parse(widget.listId))
          .then((_) {
            if (context.mounted) {
              if (createShoppingItemVm.hasCreateFoodError) {
                Toastify.show(
                  context,
                  message:
                      createShoppingItemVm.createFoodErrorMessage ??
                      'Erreur lors de l\'ajout',
                  type:
                      createShoppingItemVm.createFoodErrorType ==
                          NetworkErrorType.conflict
                      ? ToastType.info
                      : ToastType.error,
                );
              } else {
                Toastify.show(
                  context,
                  message: 'Aliment ajouté avec succès',
                  type: ToastType.success,
                );
              }
            }
          })
          .catchError((error) {
            // Erreur non catchée
            if (context.mounted) {
              Toastify.show(
                context,
                message: 'Erreur inattendue',
                type: ToastType.error,
              );
            }
          });
    }

    return Column(
      children: [
        FormBlock(
          label:
              'Quantité recommandée(en ${UnitUtils.getQuantityUnitText(createShoppingItemVm.data.unit)})',
          isRequired: false,

          child: TextField(
            controller: createShoppingItemVm.quantityController,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'ex:3.4',
            ),
          ),
        ),

        SizedBox(height: 24),

        BadgeField(
          label: 'Durée de conservation',
          value:
              '${createShoppingItemVm.data.conservationDuration.toString()} jours',
        ),

        SizedBox(height: 24),

        if (createShoppingItemVm.data.storageTips != null &&
            createShoppingItemVm.data.storageTips!.isNotEmpty)
          BadgeField(
            label: 'Conseil de conservation',
            value: createShoppingItemVm.data.storageTips!,
          ),

        SizedBox(height: 24),

        FormBlock(
          label: 'Image de l\'aliment(optionnel)',
          isRequired: false,
          child: UploadImage(
            image: createShoppingItemVm.image,
            error: createShoppingItemVm.uploadImageErrorMessage,
            onTap: () => createShoppingItemVm.pickImage(),
            onRemove: () => createShoppingItemVm.removeImage(),
          ),
        ),

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                createShoppingItemVm.data.recommendedQuantity.toString().isEmpty
                ? null
                : () async => _handleSubmit(context, createShoppingItemVm),
            child: Text('Ajouter l\'aliment'),
          ),
        ),
      ],
    );
  }
}
