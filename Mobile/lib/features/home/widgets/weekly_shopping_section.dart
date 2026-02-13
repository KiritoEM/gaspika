import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/home/widgets/weekly_shopping_empty_state.dart';
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
        !isLoading && isListEmpty ? WeeklyShoppingEmptyState() : Container(),
      ],
    );
  }

  Widget _buildWeeklyShoppingSkeleton() {
    return Column(
      children: List.generate(
        7,
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
      spacing: 16,
      children: shoppingListItems.map((item) {
        return ShoppingItemCard(item: item);
      }).toList(),
    );
  }
}
