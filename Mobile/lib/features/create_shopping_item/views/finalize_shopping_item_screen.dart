// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/widgets/upload_image.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:gaspika_mobile/shared/form_block.dart';
import 'package:gaspika_mobile/shared/progress_indicator.dart';
import 'package:gaspika_mobile/utils/app_loger.dart';
import 'package:gaspika_mobile/utils/unit_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class FinalizeShoppingItemScreen extends StatelessWidget {
  final String id;

  const FinalizeShoppingItemScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
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
          CustomProgressIndicator(value: 1),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(23, 28, 23, 23),
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
              Column(
                crossAxisAlignment: .start,
                spacing: 8,
                children: [
                  Text('Quantité recommandée'),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(127, 203, 218, 118),
                      border: BoxBorder.all(color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${createShoppingItemVm.data.recommendedQuantity.toString()} ${UnitUtils.convertUnitToBackend(createShoppingItemVm.data.unit)}',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              Column(
                spacing: 8,
                crossAxisAlignment: .start,
                children: [
                  Text('Durée de conservation'),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(127, 203, 218, 118),
                      border: BoxBorder.all(color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${createShoppingItemVm.data.conservationDuration.toString()} jour',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              FormBlock(
                label: 'Image de l\'aliment',
                isRequired: true,
                child: UploadImage(
                  image: createShoppingItemVm.image,
                  error: createShoppingItemVm.uploadImageError,
                  onTap: () => createShoppingItemVm.pickImage(),
                  onRemove: () => createShoppingItemVm.removeImage(),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ButtonWithLoader(
                  isLoading: createShoppingItemVm.isCreating,
                  text: 'Ajouter l\'aliment',
                  loadingText: 'Ajout en cours...',
                  onPressed: createShoppingItemVm.image == null
                      ? null
                      : () async {
                          final error = await createShoppingItemVm
                              .createAliment(int.parse(id));

                          if (error == null) {
                            Toastify.show(
                              context,
                              message: 'Aliment ajouté avec succès',
                              type: ToastType.success,
                            );

                            AppLogger.logger.i(int.parse(id));

                            context.go(
                              NavigationConstant.SHOPPING_LISTS_ROUTE,
                            );
                          } else {
                            Toastify.show(
                              context,
                              message: error,
                              type: ToastType.error,
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
