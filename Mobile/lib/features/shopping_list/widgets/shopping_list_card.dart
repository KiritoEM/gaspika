import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/delete_confirmation_dialog.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/update_list_dialog.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/shared/app_bottomsheet.dart';
import 'package:gaspika_mobile/shared/bottomsheet_action.dart';
import 'package:go_router/go_router.dart';

class ShoppingListCard extends StatelessWidget {
  final ShoppingList item;
  final Function(int id) onDelete;
  final Function(int id) onUpdate;

  const ShoppingListCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onUpdate,
  });

  bool get isCompleted => item.status == ShoppingListStatus.completed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '${NavigationConstant.SHOPPING_LISTS_ROUTE}/${item.id}?name=${item.name}&week=${item.weekNumber}',
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromARGB(255, 243, 242, 242),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// List name and its items count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.name!,
                                  style: TextStyle(
                                    fontSize: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCompleted)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.secondary,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/check-double.svg',
                                    width: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Text(
                          '${item.itemsCount > 0 ? item.itemsCount : 'Aucun'} aliment${item.itemsCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.fontSize!,
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.fontSize!,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        Text(
                          '${item.totalEstimatedCost} Ar',
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.fontSize!,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right actions
              GestureDetector(
                onTap: () => _buildBottomsheetActions(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.more_vert,
                    size: 22,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _buildBottomsheetActions(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      builder: (context, setModalState) {
        return [
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              const SizedBox(height: 8),
              BottomsheetAction(
                label: 'Modifier',
                icon: SvgPicture.asset('assets/icons/edit.svg', width: 18),
                onTap: () => _showEditDialog(context),
              ),

              const SizedBox(height: 16),

              BottomsheetAction(
                label: 'Supprimer',
                icon: SvgPicture.asset('assets/icons/trash.svg', width: 20),
                isDestructive: true,
                onTap: () => _showDeleteConfirmationDialog(context),
              ),
            ],
          ),
        ];
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => UpdateListDialog(
        listName: item.name!,
        onUpdate: () => onUpdate(item.id!),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteConfirmationDialog(
        listName: item.name!,
        onDelete: () => onDelete(item.id!),
      ),
    );
  }
}
