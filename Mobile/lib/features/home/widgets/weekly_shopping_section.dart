import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/shared/shopping_item_card.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class WeeklyShoppingSection extends StatelessWidget {
  bool isLoading;
  bool isListEmpty;

  WeeklyShoppingSection({
    super.key,
    this.isLoading = false,
    this.isListEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
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
                          onPressed: () {},
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
            ? _weeklyShoppingSkeleton()
            : !isListEmpty
            ? Column(
                spacing: 14,
                children: [
                  ShoppingItemCard(
                    productName: 'Pommes',
                    price: 3000,
                    quantity: 1.5,
                    quantityUnit: QuantityUnit.kilogram,
                  ),
                  ShoppingItemCard(
                    productName: 'Bananes',
                    price: 2000,
                    quantity: 2.0,
                    quantityUnit: QuantityUnit.piece,
                  ),
                  ShoppingItemCard(
                    productName: 'Lait',
                    price: 1000,
                    quantity: 1.0,
                    quantityUnit: QuantityUnit.liter,
                  ),
                ],
              )
            : Container(),

        // Empty state
        isListEmpty ? _emptyState(context) : Container(),
      ],
    );
  }

  Widget _weeklyShoppingSkeleton() {
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

  Widget _emptyState(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Text(
            'Aucun aliment disponible pour vos courses de la semaine',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {},
            label: Text('Créer une liste', style: TextStyle(fontSize: 14)),
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
