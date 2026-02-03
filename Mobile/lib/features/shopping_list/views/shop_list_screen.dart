// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/features/shopping_list/viewmodels/shopping_list_viewmodel.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/create_list_bottomsheet.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_appbar.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_card.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_status_filter.dart';
import 'package:gaspika_mobile/shared/error_state.dart';
import 'package:provider/provider.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  // list of status for filtering
  List<Map<String, dynamic>> statusDataFilter = [
    {'label': 'Tout', 'value': ShoppingListStatus.all},
    {'label': 'Complétée', 'value': ShoppingListStatus.completed},
    {'label': 'Inachevée', 'value': ShoppingListStatus.unfinished},
  ];

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
      body: SafeArea(child: _buildBody(shoppingListVm)),
      floatingActionButton: shoppingListVm.hasFetchError
          ? null
          : _buildFloatingActionButton(shoppingListVm),
    );
  }

  Widget _buildBody(ShoppingListViewModel shoppingListVm) {
    if (shoppingListVm.hasFetchError) {
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ErrorState(
          text: shoppingListVm.fetchErrorMessage,
          onRefresh: () => shoppingListVm.refreshAll(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(23, 30, 23, 23),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            ShoppingListStatusFilter(
              selectedStatus: shoppingListVm.statusFilter,
              statusList: statusDataFilter,
              onSelect: (ShoppingListStatus status) {
                shoppingListVm.changeStatusFilter(status);
              },
            ),

            SizedBox(height: 24),

            shoppingListVm.isLoadingList
                ? _shoppingListSkeleton()
                : _buildShoppingList(shoppingListVm),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ShoppingListViewModel shoppingListVm) {
    return FloatingActionButton(
      onPressed: () {
        CreateListBottomsheet.show(context);
      },
      shape: const CircleBorder(),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildShoppingList(ShoppingListViewModel shoppingListVm) {
    return Column(
      spacing: 16,
      children: shoppingListVm.shoppingWeekItems
          .map(
            (item) => ShoppingListCard(
              item: item,
              succesMessage: 'Liste de courses supprimée avec succès.',
              errorMessage: shoppingListVm.deleteErrorMessage,
              onDelete: (id, resultCallback) async {
                await shoppingListVm.deleteShoppingList(id);

                if (!mounted) return;

                if (!shoppingListVm.hasDeleteError &&
                    !shoppingListVm.isDeletingList) {
                  resultCallback(true, null);
                } else {
                  resultCallback(false, shoppingListVm.deleteErrorMessage);
                }
              },
            ),
          )
          .toList(),
    );
  }

  Widget _shoppingListSkeleton() {
    return Column(
      children: List.generate(
        7,
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
