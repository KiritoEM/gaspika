// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/features/shopping_list/viewmodels/shopping_list_viewmodel.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_appbar.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_card.dart';
import 'package:provider/provider.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final shoppingListVm = Provider.of<ShoppingListViewModel>(
        context,
        listen: false,
      );
      await shoppingListVm.fetchShoppingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListVm = context.watch<ShoppingListViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: ShoppingListAppbar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(23, 30, 23, 23),
            child: Column(
              children: [
                shoppingListVm.isLoadingList
                    ? _shoppingListSkeleton()
                    : _buildShoppingList(shoppingListVm),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 0.4,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildShoppingList(ShoppingListViewModel shoppingListVm) {
    return Column(
      spacing: 14,
      children: shoppingListVm.shoppingWeekItems
          .map(
            (item) => ShoppingListCard(
              listName: item.name ?? '',
              itemsCount: item.itemCount,
              isCompleted: item.isCompleted,
            ),
          )
          .toList(),
    );
  }

  Widget _shoppingListSkeleton() {
    return Column(
      children: List.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonLine(
            style: SkeletonLineStyle(
              height: 85,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
