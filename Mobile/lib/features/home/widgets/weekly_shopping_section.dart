import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/shared/shopping_item_card.dart';

class WeeklyShoppingSection extends StatelessWidget {
  const WeeklyShoppingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COURSES DE LA SEMAINE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            TextButton.icon(
              onPressed: () {},
              label: Text('Voir tout', style: TextStyle(color: Colors.orange)),
              iconAlignment: IconAlignment.end,
              icon: Icon(Icons.arrow_right_alt, color: Colors.orange),
            ),
          ],
        ),

        SizedBox(height: 2),

        // Shopping items list
        Column(
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
        ),
      ],
    );
  }
}
