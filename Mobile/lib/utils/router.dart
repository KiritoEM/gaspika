import 'package:gaspika_mobile/features/onboarding/views/onboarding_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, state) => OnboardingScreen())],
  );
}
