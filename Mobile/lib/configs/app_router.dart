/// App router handler
library;

import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/auth/views/login_screen.dart';
import 'package:gaspika_mobile/features/auth/views/register_screen.dart';
import 'package:gaspika_mobile/features/home/views/home_screen.dart';
import 'package:gaspika_mobile/features/onboarding/views/onboarding_screen.dart';
import 'package:gaspika_mobile/features/shopping_list/views/shop_list_screen.dart';
import 'package:gaspika_mobile/shared/scaffold_navigation_bar.dart';
import 'package:gaspika_mobile/utils/guards/role_guard.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: NavigationConstant.SHOPPING_LIST_ROUTE,
    routes: [
      GoRoute(
        path: NavigationConstant.DEFAULT_ROUTE,
        builder: (_, state) => OnboardingScreen(),
        redirect: (context, state) => RoleGuard().redirectIfAuthentificated(),
      ),
      GoRoute(
        path: NavigationConstant.LOGIN_ROUTE,
        builder: (_, state) => LoginScreen(),
      ),
      GoRoute(
        path: NavigationConstant.REGISTER_ROUTE,
        builder: (_, state) => RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldNavigationBar(child: child),
        routes: [
          GoRoute(
            path: NavigationConstant.HOME_ROUTE,
            builder: (_, state) => HomeScreen(),
            redirect: (context, state) => RoleGuard().checkAccess(),
          ),
          GoRoute(
            path: NavigationConstant.SHOPPING_LIST_ROUTE,
            builder: (_, state) => ShopListScreen(),
            redirect: (context, state) => RoleGuard().checkAccess(),
          ),
        ],
      ),
    ],
  );
}
