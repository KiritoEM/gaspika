import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/bell.svg',
            width: 130,
            colorFilter: ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Aucune notification \npour le moment.',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
