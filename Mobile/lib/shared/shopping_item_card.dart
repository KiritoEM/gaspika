import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/utils/unit_utils.dart';
import 'package:go_router/go_router.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingListItem item;
  final VoidCallback? onTap;

  const ShoppingItemCard({super.key, required this.item, this.onTap});

  bool get isCompleted => item.status == ShoppingItemStatus.purchased;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '${NavigationConstant.SHOPPING_LISTS_ITEMS_ROUTE}/${item.id}',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 243, 242, 242),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Product info
              Expanded(
                child: Row(
                  spacing: 14,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: AppColors.surface,
                        child: Image.network(
                          item.image?.path ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.shopping_basket,
                              size: 30,
                              color: AppColors.mutedForeground,
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.foodName,
                                  style: TextStyle(
                                    fontSize: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? Colors.white
                                        : AppColors.foreground,
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
                                    color: Colors.blue,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/check-double.svg',
                                    width: 14,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            '${item.price.toString()} Ar',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              color: isCompleted
                                  ? Colors.white.withOpacity(0.8)
                                  : AppColors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.recommendedQuantity} ${UnitUtils.getQuantityUnitText(item.quantityUnit)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
