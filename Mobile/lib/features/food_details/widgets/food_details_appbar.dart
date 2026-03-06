import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class FoodDetailsAppbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenAction;
  final VoidCallback onGoBack;

  const FoodDetailsAppbar({
    super.key,
    required this.onOpenAction,
    required this.onGoBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
      child: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/chevron-left.svg', width: 40),
          onPressed: () => onGoBack(),
        ),
        title: const Text(
          'Détails de l\'aliment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        titleSpacing: 4,
        actions: [
          GestureDetector(
            onTap: () => onOpenAction(),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.more_vert,
                size: 22,
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
