import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class ShoppingListAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onFilter;
  const ShoppingListAppbar({super.key, required this.onFilter});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Listes de courses',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        actions: [
          IconButton(
            onPressed: () => onFilter(),
            icon: SvgPicture.asset('assets/icons/arrow-sort.svg', width: 24),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}
