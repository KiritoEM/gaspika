// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/shopping_list_items/viewmodels/shopping_list_items_viewmodel.dart';
import 'package:gaspika_mobile/shared/shopping_item_card.dart';
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
      await shoppingItemsVm.fetchShoppingItemsById(int.parse(widget.id));
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
    final listName = GoRouterState.of(context).extra as String;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(23, 10, 23, 23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Courses ${listName[0].toLowerCase()}${listName.substring(1)}',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Shopping items list
              Expanded(
                child: shoppingItemsVm.isLoadingItems
                    ? _buildItemsSkeleton()
                    : _buildShoppingItems(shoppingItemsVm),
              ),

              // Add button
              shoppingItemsVm.isLoadingItems
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.only(top: 16),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/create-shopping-item/${widget.id}'),
                        label: const Text('Ajouter un aliment'),
                        icon: const Icon(Icons.add),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingItems(ShoppingItemsViewModel shoppingItemsVm) {
    if (shoppingItemsVm.shoppingItems.isEmpty) {
      return Center(
        child: Text(
          'Aucun aliment ajouté dans cette liste',
          style: TextStyle(fontSize: 16, color: AppColors.mutedForeground),
          textAlign: .center,
        ),
      );
    }

    return ListView.separated(
      itemCount: shoppingItemsVm.shoppingItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = shoppingItemsVm.shoppingItems[index];
        return ShoppingItemCard(item: item);
      },
    );
  }

  Widget _buildItemsSkeleton() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return const SkeletonLine(
          style: SkeletonLineStyle(
            height: 100,
            width: double.infinity,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        );
      },
    );
  }
}
