import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';

class ShoppingItemCard extends StatelessWidget {
  String productName;
  int price;
  double quantity;
  QuantityUnit quantityUnit;
  String? imageUrl;

  ShoppingItemCard({
    super.key,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.quantityUnit,
    this.imageUrl,
  });

  String getQuantityUnitText() {
    switch (quantityUnit) {
      case QuantityUnit.kilogram:
        return 'kg';
      case QuantityUnit.liter:
        return 'L';
      case QuantityUnit.gram:
        return 'g';
      case QuantityUnit.milliliter:
        return 'ml';
      case QuantityUnit.piece:
        return 'pcs';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.shopping_basket,
                                  size: 30,
                                  color: AppColors.mutedForeground,
                                );
                              },
                            )
                          : Icon(
                              Icons.shopping_basket,
                              size: 30,
                              color: AppColors.mutedForeground,
                            ),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          productName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${price.toString()} Ar',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.mutedForeground,
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
                '$quantity ${getQuantityUnitText()}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
