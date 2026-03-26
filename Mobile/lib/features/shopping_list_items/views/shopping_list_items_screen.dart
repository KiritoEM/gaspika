// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/configs/router_observer.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/shopping_list_items/viewmodels/shopping_list_items_viewmodel.dart';
import 'package:gaspika_mobile/features/shopping_list_items/widgets/shopping_items_skeleton.dart';
import 'package:gaspika_mobile/shared/error_state.dart';
import 'package:gaspika_mobile/shared/shopping_item_card.dart';
import 'package:gaspika_mobile/utils/date.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ShoppingListItemsScreen extends StatefulWidget {
  final String listId;
  final String listName;
  final int weekNumber;

  const ShoppingListItemsScreen({
    super.key,
    required this.listId,
    required this.listName,
    required this.weekNumber,
  });

  @override
  State<ShoppingListItemsScreen> createState() =>
      _ShoppingListItemsScreenState();
}

class _ShoppingListItemsScreenState extends State<ShoppingListItemsScreen>
    with RouteAware {
  late ShoppingItemsViewModel _shoppingItemsVm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shoppingItemsVm = Provider.of<ShoppingItemsViewModel>(
      context,
      listen: false,
    );

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _shoppingItemsVm.fetchShoppingItems(int.parse(widget.listId));
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  void didPopNext() {
    _shoppingItemsVm.refreshItems(int.parse(widget.listId));
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItemsVm = Provider.of<ShoppingItemsViewModel>(context);

    final isCurrentOrFutureWeek =
        DateUtilities.getCurrentWeekNumberISO() <= widget.weekNumber;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/chevron-left.svg', width: 40),
          onPressed: () => context.go(NavigationConstant.SHOPPING_LISTS_ROUTE),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              shoppingItemsVm.refreshItems(int.parse(widget.listId)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(23, 10, 23, 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listName,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(child: _buildBody(shoppingItemsVm)),

                shoppingItemsVm.isLoadingItems
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.only(top: 16),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isCurrentOrFutureWeek
                              ? () => context.push(
                                  '${NavigationConstant.CREATE_SHOPPING_ITEM_ROUTE}/${widget.listId}?name=${widget.listName}&week=${widget.weekNumber}',
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

  Widget _buildBody(ShoppingItemsViewModel shoppingItemsVm) {
    if (shoppingItemsVm.isLoadingItems) {
      return ShoppingItemsSkeleton();
    }

    if (shoppingItemsVm.hasError) {
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ErrorState(
          text: shoppingItemsVm.errorMessage,
          onRefresh: () =>
              shoppingItemsVm.refreshShoppingItems(int.parse(widget.listId)),
        ),
      );
    }

    if (shoppingItemsVm.shoppingItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/food-not-found.svg', width: 200),
            const SizedBox(height: 16),
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
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: shoppingItemsVm.shoppingItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = shoppingItemsVm.shoppingItems[index];
        return ShoppingItemCard(item: item);
      },
    );
  }
}
