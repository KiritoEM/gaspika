// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/features/shopping_lists/viewmodels/shopping_lists_viewmodel.dart';
import 'package:gaspika_mobile/features/shopping_lists/widgets/shopping_lists_appbar.dart';
import 'package:gaspika_mobile/features/shopping_lists/widgets/shopping_lists_card.dart';
import 'package:gaspika_mobile/shared/app_bottomsheet.dart';
import 'package:gaspika_mobile/shared/button_with_loader.dart';
import 'package:gaspika_mobile/shared/date_picker.dart';
import 'package:gaspika_mobile/shared/snackbar.dart';
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

      floatingActionButton: _buildFloatingActionButton(shoppingListVm),
    );
  }

  Widget _buildFloatingActionButton(ShoppingListViewModel shoppingListVm) {
    return FloatingActionButton(
      onPressed: () {
        DateTime modalDate = shoppingListVm.selectedDate;

        AppBottomSheet.show(
          context: context,
          builder: (context, setModalState) {
            return [
              Column(
                children: [
                  Text(
                    'Générer une liste',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(
                        context,
                      ).textTheme.titleLarge?.fontSize,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text('Choisissez une semaine(cliquer sur la date)'),
                      DatePicker(
                        value: modalDate,
                        onSelectDate: (date) {
                          setModalState(() {
                            modalDate = date;
                          });

                          shoppingListVm.setSelectedDate(date);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonWithLoader(
                      isLoading: shoppingListVm.isGeneratingList,
                      text: 'Générer',
                      loadingText: 'Genération en cours...',
                      onPressed: () async {
                        final response = await shoppingListVm
                            .generateShoppingList();

                        SnackbarUtils.showInSnackBar(
                          context,
                          response.message!,
                          type: response.success!
                              ? SnackbarType.success
                              : SnackbarType.error,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ];
          },
        );
      },
      shape: const CircleBorder(),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildShoppingList(ShoppingListViewModel shoppingListVm) {
    return Column(
      spacing: 14,
      children: shoppingListVm.shoppingWeekItems
          .map(
            (item) => ShoppingListCard(
              id: item.id!,
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
