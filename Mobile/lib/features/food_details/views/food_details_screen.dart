// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/features/food_details/viewmodels/food_details_viewmodel.dart';
import 'package:gaspika_mobile/features/food_details/widgets/food_details_appbar.dart';
import 'package:gaspika_mobile/features/food_details/widgets/food_details_bottomsheet.dart';
import 'package:gaspika_mobile/shared/badge_field.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:gaspika_mobile/shared/loader_with_overlay.dart';
import 'package:gaspika_mobile/utils/unit_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';
import 'package:provider/provider.dart';

class FoodDetailsScreen extends StatefulWidget {
  final String id;

  const FoodDetailsScreen({super.key, required this.id});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsViewScreenState();
}

class _FoodDetailsViewScreenState extends State<FoodDetailsScreen> {
  Future _handleDeleteItem(
    BuildContext context,
    int itemId,
    FoodDetailsViewmodel foodDetailsVm,
  ) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      useRootNavigator: true,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) {
        return LoaderWithOverlay(text: 'Supression en cours');
      },
    );

    await foodDetailsVm.deleteItem(itemId);

    Navigator.of(context, rootNavigator: true).pop(true);

    if (!foodDetailsVm.hasDeleteError && !foodDetailsVm.isDeletingItem) {
      context.pop(true);
    } else {
      Toastify.show(
        rootContext,
        message: foodDetailsVm.deleteErrorMessage,
        type: ToastType.error,
      );
    }
  }

  Future _handleUpdateItem(
    BuildContext context,
    int itemId,
    FoodDetailsViewmodel foodDetailsVm,
  ) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      useRootNavigator: true,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) {
        return LoaderWithOverlay(text: 'Mise à jour en cours');
      },
    );

    await foodDetailsVm.updateItem(itemId);

    Navigator.of(context, rootNavigator: true).pop(true);

    if (!foodDetailsVm.hasUpdateError && !foodDetailsVm.isUpdatingItem) {
      Toastify.show(
        rootContext,
        message: 'Aliment mis à jour avec succès',
        type: ToastType.success,
      );
    } else {
      Toastify.show(
        rootContext,
        message: foodDetailsVm.updateErrorMessage,
        type: ToastType.error,
      );
    }
  }

  Future _handleCompleteItem(FoodDetailsViewmodel foodDetailsVm) async {
    await foodDetailsVm.markItemAsComplete(int.parse(widget.id));

    if (!mounted) return;

    if (foodDetailsVm.hasError) {
      Toastify.show(
        context,
        message: foodDetailsVm.errorMessage,
        type: ToastType.error,
      );
    } else {
      Toastify.show(
        context,
        message: 'Aliment marqué comme acheté',
        type: ToastType.success,
      );
      context.pop(true);
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final foodDetailsVm = Provider.of<FoodDetailsViewmodel>(
        context,
        listen: false,
      );
      await foodDetailsVm.fetchItemDetails(int.parse(widget.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final foodDetailsVm = Provider.of<FoodDetailsViewmodel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FoodDetailsAppbar(
        onOpenAction: () {
          FoodDetailsBottomsheet.show(
            context: context,
            isAvailable: foodDetailsVm.currentItem?.isAvailable ?? false,
            onUpdate: () =>
                _handleUpdateItem(context, int.parse(widget.id), foodDetailsVm),
            onDelete: () =>
                _handleDeleteItem(context, int.parse(widget.id), foodDetailsVm),
          );
        },
        onGoBack: () => {context.pop(true)},
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(23, 10, 23, 23),
          child:
              foodDetailsVm.isLoadingItem || foodDetailsVm.currentItem == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildContent(foodDetailsVm),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      width: double.infinity,
                      child: _buildActionButton(foodDetailsVm),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildActionButton(FoodDetailsViewmodel foodDetailsVm) {
    final item = foodDetailsVm.currentItem;
    final isPurchased = item?.status == ShoppingItemStatus.purchased;
    final isLoading = foodDetailsVm.isMarkingItem;

    return ButtonWithLoader(
      text: isPurchased ? 'Déjà acheté' : 'Marquer comme acheté',
      loadingText: 'Marquage en cours...',
      isLoading: isLoading,
      onPressed: (isPurchased || item?.isAvailable == false)
          ? null
          : () => _handleCompleteItem(foodDetailsVm),
      style: isPurchased
          ? ElevatedButton.styleFrom(
              backgroundColor: AppColors.mutedForeground.withOpacity(0.3),
            )
          : null,
    );
  }

  Widget _buildContent(FoodDetailsViewmodel vm) {
    final item = vm.currentItem!;
    final unitText = UnitUtils.getQuantityUnitText(item.quantityUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                item.foodName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (item.status == ShoppingItemStatus.purchased)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
                child: SvgPicture.asset(
                  'assets/icons/check-double.svg',
                  width: 16,
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Text(
              '${item.recommendedQuantity} $unitText',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Text(
              ' · ',
              style: TextStyle(fontSize: 18, color: AppColors.primary),
            ),
            Text(
              '${item.price} Ar/$unitText',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Text(
              ' · ',
              style: TextStyle(fontSize: 18, color: AppColors.primary),
            ),
            Text(
              '${item.totalPrice} Ar',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (item.conservationDuration != null)
          Column(
            children: [
              BadgeField(
                label: 'Durée de conservation',
                value: '${item.conservationDuration.toString()} jours',
              ),
              SizedBox(height: 24),
            ],
          ),

        if (item.storageTips != null && item.storageTips != null)
          BadgeField(
            label: 'Conseil de conservation',
            value: item.storageTips!,
          ),

        const SizedBox(height: 24),

        item.image != null
            ? AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item.image!.path,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.shopping_basket,
                          size: 64,
                          color: AppColors.mutedForeground,
                        ),
                      );
                    },
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
