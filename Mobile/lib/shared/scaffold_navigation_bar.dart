import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaspika_mobile/configs/app_colors.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:go_router/go_router.dart';

class ScaffoldNavigationBar extends StatefulWidget {
  final Widget child;

  const ScaffoldNavigationBar({super.key, required this.child});

  @override
  State<ScaffoldNavigationBar> createState() => _ScaffoldNavigationBarState();
}

class _ScaffoldNavigationBarState extends State<ScaffoldNavigationBar> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.toString();

    final routeIndexMap = {'/home': 0, '/shopping-list': 1};

    int newIndex = 0;
    routeIndexMap.forEach((route, index) {
      if (location.startsWith(route)) {
        newIndex = index;
      }
    });

    if (_currentIndex != newIndex) {
      setState(() => _currentIndex = newIndex);
    }
  }

  void _handleChangeTab(int index) {
    if (index < 3) {
      setState(() => _currentIndex = index);

      final routes = ['/home', '/shopping-list'];
      context.go(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
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
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? AppColors.primary
                          : AppColors.mutedForeground,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: route['label'],
                );
              })
              .toList(),
        ),
      ),
    );
  }
}
