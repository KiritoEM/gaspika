import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({super.key, required this.currentIndex});

  void _handleChangeTab(BuildContext context, int index) {
    if (index == currentIndex) return;

    context.go(NavigationConstant.BOTTOM_NAVIGATION_ROUTES[index]['route']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: NavigationBar(
        elevation: 0,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _handleChangeTab(context, index),
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        destinations: NavigationConstant.BOTTOM_NAVIGATION_ROUTES
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final route = entry.value;
              final isSelected = currentIndex == index;

              return NavigationDestination(
                icon: SvgPicture.asset(
                  route['icon'],
                  width: route['icon_width'],
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.primary : AppColors.mutedForeground,
                    BlendMode.srcIn,
                  ),
                ),
                label: route['label'],
              );
            })
            .toList(),
      ),
    );
  }
}
