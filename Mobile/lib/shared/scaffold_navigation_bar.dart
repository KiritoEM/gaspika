import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';

class ScaffoldNavigationBar extends StatefulWidget {
  final Widget child;

  const ScaffoldNavigationBar({super.key, required this.child});

  @override
  State<ScaffoldNavigationBar> createState() => _ScaffoldNavigationBarState();
}

class _ScaffoldNavigationBarState extends State<ScaffoldNavigationBar> {
  int _currentIndex = 0;

  void _handleChangeTab(int index) {
    setState(() => _currentIndex = index);
    // final routes = ['/home', '/cart', '/profile'];
    // context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _handleChangeTab,
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        destinations: NavigationConstant.BOTTOM_NAVIGATION_ROUTES
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final route = entry.value;
              final isSelected = _currentIndex == index;

              return NavigationDestination(
                icon: SvgPicture.asset(
                  route['icon'],
                  width: 26,
                  height: 26,
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
