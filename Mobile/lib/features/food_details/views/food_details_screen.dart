// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/features/food_details/viewmodels/food_details_viewmodel.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
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
    final foodDetailsVm = context.watch<FoodDetailsViewmodel>();

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
          'Détails de l\'aliment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        titleSpacing: 4,
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
      onPressed: isPurchased
          ? null
          : () async {
              await foodDetailsVm.markItemAsComplete(int.parse(widget.id));

              if (!mounted) return;

              if (foodDetailsVm.hasError) {
                Toastify.show(context, message: foodDetailsVm.errorMessage);
              } else {
                Toastify.show(context, message: 'Aliment marqué comme acheté');
                context.pop();
              }
            },
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
              '${item.price} Ar',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.image.path,
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
        ),
      ],
    );
  }
}
