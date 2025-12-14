import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class ShoppingListCard extends StatelessWidget {
  final String listName;
  final int itemsCount;
  final bool isCompleted;

  const ShoppingListCard({
    super.key,
    required this.listName,
    required this.itemsCount,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                        child: Text(
                          'Courses $listName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
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
                  const SizedBox(height: 5),
                  Text(
                    '$itemsCount course${itemsCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Right actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 22),
              onSelected: (value) {},
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
