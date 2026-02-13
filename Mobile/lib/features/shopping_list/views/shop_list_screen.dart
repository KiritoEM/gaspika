// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/features/shopping_list/viewmodels/shopping_list_viewmodel.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/filter_bottomsheet.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_skeleton.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/create_list_bottomsheet.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_appbar.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_card.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/shopping_list_status_filter.dart';
import 'package:gaspika_mobile/features/shopping_list_items/views/widgets/empty_state.dart';
import 'package:gaspika_mobile/shared/error_state.dart';
import 'package:my_toastify/my_toastify.dart';
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

  Future handleDeleteList(
    int listId,
    ShoppingListViewModel shoppingListVm,
  ) async {
    await shoppingListVm.deleteShoppingList(listId);

    if (!mounted) return;

    if (!shoppingListVm.hasDeleteError && !shoppingListVm.isDeletingList) {
      Toastify.show(
        context,
        message: 'Liste de courses supprimée avec succès.',
        type: ToastType.success,
      );
    } else {
      Toastify.show(
        context,
        message: shoppingListVm.deleteErrorMessage,
        type: ToastType.error,
      );
    }
  }

  Future handleUpdateList(
    int listId,
    ShoppingListViewModel shoppingListVm,
  ) async {
    await shoppingListVm.updateShoppingList(listId);

    if (!mounted) return;

    if (!shoppingListVm.hasUpdateError && !shoppingListVm.isUpdatingList) {
      Toastify.show(
        context,
        message: 'Liste de courses mis a jour avec succès.',
        type: ToastType.success,
      );
    } else {
      Toastify.show(
        context,
        message: shoppingListVm.updateErrorMessage,
        type: ToastType.error,
      );
    }
  }

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
      appBar: ShoppingListAppbar(
        onFilter: () {
          FilterBottomsheet.show(
            context,
            shoppingListVm.periodFilter,
            (PeriodFilterEnum? periodFilter) {
              shoppingListVm.setFilterPeriod(periodFilter);
            },
            () {
              shoppingListVm.setFilterPeriod(null);
            },
          );
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => shoppingListVm.refreshShoppingList(),
          child: _buildBody(shoppingListVm),
        ),
      ),
      floatingActionButton: shoppingListVm.hasFetchError
          ? null
          : _buildFloatingActionButton(shoppingListVm),
    );
  }

  Widget _buildBody(ShoppingListViewModel shoppingListVm) {
    bool isListEmpty = shoppingListVm.shoppingWeekItems.isEmpty;

    if (shoppingListVm.hasFetchError) {
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ErrorState(
          text: shoppingListVm.fetchErrorMessage,
          onRefresh: () => shoppingListVm.refreshShoppingList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(23, 16, 23, 0),
          child: ShoppingListStatusFilter(
            selectedStatus: shoppingListVm.statusFilter,
            statusList: statusDataFilter,
            onSelect: (ShoppingListStatus status) {
              shoppingListVm.changeStatusFilter(status);
            },
          ),
        ),

        SizedBox(height: 24),

        // Contenu scrollable
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                children: [
                  if (shoppingListVm.isLoadingList)
                    ShoppingListSkeleton()
                  else if (!isListEmpty)
                    _buildShoppingList(shoppingListVm)
                  else
                    ShoppingListEmptyState(),
                ],
              ),
            ),
          ),
        ),
      ],
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
              onUpdate: (id) async {
                handleUpdateList(id, shoppingListVm);
              },
              onDelete: (id) async {
                handleDeleteList(id, shoppingListVm);
              },
            ),
          )
          .toList(),
    );
  }
}
