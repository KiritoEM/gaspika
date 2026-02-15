// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/shared/badge_field.dart';
import 'package:gaspika_mobile/shared/upload_image.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:gaspika_mobile/shared/progress_indicator.dart';
import 'package:gaspika_mobile/utils/unit_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class FinalizeShoppingItemScreen extends StatefulWidget {
  final String listId;

  const FinalizeShoppingItemScreen({super.key, required this.listId});

  @override
  State<FinalizeShoppingItemScreen> createState() =>
      _FinalizeShoppingItemScreenState();
}

class _FinalizeShoppingItemScreenState
    extends State<FinalizeShoppingItemScreen> {
  @override
  void initState() {
    super.initState();

    final createShoppingItemVm = Provider.of<CreateShoppingItemViewModel>(
      context,
      listen: false,
    );

    // init quantity input default value
    createShoppingItemVm.quantityController.text = createShoppingItemVm
        .data
        .recommendedQuantity
        .toString();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/chevron-left.svg', width: 40),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Ajouter un aliment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        titleSpacing: 4,
      ),
      body: Column(
        children: [
          CustomProgressIndicator(activeIndex: 1),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                child: _buildContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final createShoppingItemVm = context.watch<CreateShoppingItemViewModel>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Header
            Column(
              crossAxisAlignment: .start,
              spacing: 8,
              children: [
                Text(
                  'Informations complémentaires',
                  style: TextStyle(
                    fontSize: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.fontSize!,
                    fontWeight: .bold,
                  ),
                ),

                Text(
                  'Consultez les informations prédites et téléchargez une image de l\'aliment pour finaliser l\'ajout.',
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
              ],
            ),

            SizedBox(height: 32),

            Column(
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
                        createShoppingItemVm.data.recommendedQuantity
                            .toString()
                            .isEmpty
                        ? null
                        : () async =>
                              _handleSubmit(context, createShoppingItemVm),
                    child: Text('Ajouter l\'aliment'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
