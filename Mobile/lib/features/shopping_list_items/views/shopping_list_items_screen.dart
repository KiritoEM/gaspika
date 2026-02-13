// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/shopping_list_items/viewmodels/shopping_list_items_viewmodel.dart';
import 'package:gaspika_mobile/features/shopping_list_items/views/widgets/shopping_items_skeleton.dart';
import 'package:gaspika_mobile/shared/shopping_item_card.dart';
import 'package:gaspika_mobile/utils/date.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ShoppingListItemsScreen extends StatefulWidget {
  final String id;

  const ShoppingListItemsScreen({super.key, required this.id});

  @override
  State<ShoppingListItemsScreen> createState() =>
      _ShoppingListItemsScreenState();
}

class _ShoppingListItemsScreenState extends State<ShoppingListItemsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final shoppingItemsVm = Provider.of<ShoppingItemsViewModel>(
        context,
        listen: false,
      );
      await shoppingItemsVm.fetchShoppingItems(int.parse(widget.id));
    });
  }

  @override
  void dispose() {
    // Clear items when leaving
    final shoppingItemsVm = Provider.of<ShoppingItemsViewModel>(
      context,
      listen: false,
    );
    shoppingItemsVm.clearItems();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItemsVm = context.watch<ShoppingItemsViewModel>();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final listName = extra?['name'] as String? ?? 'Course inconnue';
    final weekNumber = extra?['week_number'] as int? ?? 0;

    final isCurrentOrFutureWeek =
        DateUtilities.getCurrentWeekNumberISO() <= weekNumber;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => context.go('/shopping-list'),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => shoppingItemsVm.refreshItems(int.parse(widget.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(23, 10, 23, 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listName,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Shopping items list
                Expanded(
                  child: shoppingItemsVm.isLoadingItems
                      ? ShoppingItemsSkeleton()
                      : _buildShoppingItems(shoppingItemsVm),
                ),

                // Add button
                shoppingItemsVm.isLoadingItems
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.only(top: 16),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isCurrentOrFutureWeek == true
                              ? () => context.push(
                                  '/create-shopping-item/${widget.id}',
                                )
                              : null,
                          label: const Text('Ajouter un aliment'),
                          icon: const Icon(Icons.add),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingItems(ShoppingItemsViewModel shoppingItemsVm) {
    if (shoppingItemsVm.shoppingItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: .min,
          spacing: 16,
          children: [
            SvgPicture.asset('assets/images/food-not-found.svg', width: 200),

            Text(
              'Aucun aliment ajouté dans \ncette liste',
              style: TextStyle(fontSize: 16, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: shoppingItemsVm.shoppingItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = shoppingItemsVm.shoppingItems[index];
        return ShoppingItemCard(item: item);
      },
    );
  }
}
