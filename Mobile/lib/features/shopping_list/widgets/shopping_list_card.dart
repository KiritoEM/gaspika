import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/features/shopping_list/widgets/delete_confirmation_dialog.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/shared/app_bottomsheet.dart';
import 'package:gaspika_mobile/shared/bottomsheet_action.dart';
import 'package:go_router/go_router.dart';
import 'package:my_toastify/my_toastify.dart';

class ShoppingListCard extends StatelessWidget {
  final ShoppingList item;
  final String succesMessage;
  final String errorMessage;
  final Function(int id, Function(bool success, String? error)) onDelete;

  const ShoppingListCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.succesMessage = '',
    this.errorMessage = '',
  });

  bool get isCompleted => item.status == ShoppingListStatus.completed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/shopping-list/${item.id}',
          extra: {'name': item.name, 'week_number': item.weekNumber},
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
                    Text(
                      '${item.itemsCount} aliment${item.itemsCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.fontSize!,
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
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
              const SizedBox(height: 16),
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

  void _showEditDialog(BuildContext context) {}

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteConfirmationDialog(
        listName: item.name!,
        onDelete: () {
          onDelete(item.id!, (success, error) {
            if (success) {
              Toastify.show(
                context,
                message: succesMessage,
                type: ToastType.success,
              );
            } else {
              Toastify.show(
                context,
                message: errorMessage,
                type: ToastType.error,
              );
            }
          });
        },
      ),
    );
  }
}
