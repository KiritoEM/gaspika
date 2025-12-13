/// App router handler
library;

import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/auth/views/login_screen.dart';
import 'package:gaspika_mobile/features/auth/views/register_screen.dart';
import 'package:gaspika_mobile/features/onboarding/views/onboarding_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: NavigationConstant.DEFAULT_ROUTE,
    routes: [
      GoRoute(
        path: NavigationConstant.DEFAULT_ROUTE,
        builder: (_, state) => OnboardingScreen(),
      ),
      GoRoute(
        path: NavigationConstant.LOGIN_ROUTE,
        builder: (_, state) => LoginScreen(),
      ),
      GoRoute(
        path: NavigationConstant.REGISTER_ROUTE,
        builder: (_, state) => RegisterScreen(),
      ),
    ],
  );
}
