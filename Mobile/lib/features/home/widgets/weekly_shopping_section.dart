import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/models/domains-object/shopping.dart';
import 'package:gaspika_mobile/shared/shopping_item_card.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:go_router/go_router.dart';

class WeeklyShoppingSection extends StatelessWidget {
  bool isLoading;
  List<ShoppingListItem> shoppingListItems;

  WeeklyShoppingSection({
    super.key,
    this.isLoading = false,
    this.shoppingListItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    bool isListEmpty = shoppingListItems.isEmpty;

    return Column(
      children: [
        // Header
        isListEmpty
            ? Container()
            : Row(
                mainAxisAlignment: isLoading ? .start : .spaceBetween,
                children: [
                  Text(
                    'COURSES DE LA SEMAINE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),

                  isLoading
                      ? Container()
                      : TextButton.icon(
                          onPressed: () {
                            context.go(NavigationConstant.SHOPPING_LISTS_ROUTE);
                          },
                          label: Text(
                            'Voir tout',
                            style: TextStyle(color: Colors.orange),
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            Icons.arrow_right_alt,
                            color: Colors.orange,
                          ),
                        ),
                ],
              ),

        SizedBox(height: isLoading ? 14 : 2),

        // Shopping items list
        isLoading
            ? _buildWeeklyShoppingSkeleton()
            : !isListEmpty
            ? _buildShoppingList()
            : Container(),

        // Empty state
        !isLoading && isListEmpty ? _buildEmptyState(context) : Container(),
      ],
    );
  }

  Widget _buildWeeklyShoppingSkeleton() {
    return Column(
      children: List.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonLine(
            style: SkeletonLineStyle(
              height: 75,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingList() {
    return Column(
      spacing: 14,
      children: shoppingListItems.map((item) {
        return ShoppingItemCard(item: item);
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Column(
        spacing: 24,
        children: [
          SvgPicture.asset('assets/images/food-not-found.svg', width: 200),

          Column(
            children: [
              Text(
                'Aucun aliment disponible pour vos courses de la semaine',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  context.go('/shopping-list');
                },
                label: Text(
                  'Consulter la liste',
                  style: TextStyle(fontSize: 14),
                ),
                icon: Icon(Icons.arrow_right_alt, size: 20),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
