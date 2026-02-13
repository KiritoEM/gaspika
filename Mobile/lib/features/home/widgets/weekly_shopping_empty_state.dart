import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:go_router/go_router.dart';

class WeeklyShoppingEmptyState extends StatelessWidget {
  const WeeklyShoppingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
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
                icon: SvgPicture.asset(
                  'assets/icons/arrow-right-broken.svg',
                  width: 20,
                ),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
