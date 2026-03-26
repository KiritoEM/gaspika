/// App router handler
library;

import 'package:gaspika_mobile/configs/router_observer.dart';
import 'package:gaspika_mobile/constants/navigation_constant.dart';
import 'package:gaspika_mobile/features/auth/views/login_screen.dart';
import 'package:gaspika_mobile/features/auth/views/register_screen.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/create_shopping_item_screen.dart';
import 'package:gaspika_mobile/features/create_shopping_item/views/finalize_shopping_item_screen.dart';
import 'package:gaspika_mobile/features/food_details/views/food_details_screen.dart';
import 'package:gaspika_mobile/features/home/views/home_screen.dart';
import 'package:gaspika_mobile/features/notification/views/notifications_screen.dart';
import 'package:gaspika_mobile/features/onboarding/views/onboarding_screen.dart';
import 'package:gaspika_mobile/features/shopping_list/views/shopping_list_screen.dart';
import 'package:gaspika_mobile/features/shopping_list_items/views/shopping_list_items_screen.dart';
import 'package:gaspika_mobile/shared/scaffold_navigation_bar.dart';
import 'package:gaspika_mobile/utils/guards/role_guard.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    observers: [routeObserver],
    initialLocation: NavigationConstant.DEFAULT_ROUTE,
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
            path: NavigationConstant.SHOPPING_LISTS_ROUTE,
            builder: (_, state) => ShoppingListScreen(),
            redirect: (context, state) => RoleGuard().checkAccess(),
          ),
        ],
      ),
      GoRoute(
        path: '${NavigationConstant.SHOPPING_LISTS_ROUTE}/:listId',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          final listName =
              state.uri.queryParameters['name'] ?? 'Course inconnue';
          final week =
              int.tryParse(state.uri.queryParameters['week'] ?? '0') ?? 0;

          return ShoppingListItemsScreen(
            listId: listId,
            listName: listName,
            weekNumber: week,
          );
        },
        redirect: (context, state) => RoleGuard().checkAccess(),
      ),
      GoRoute(
        path: '${NavigationConstant.SHOPPING_LISTS_ITEMS_ROUTE}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;

          return FoodDetailsScreen(id: id);
        },
        redirect: (context, state) => RoleGuard().checkAccess(),
      ),
      GoRoute(
        path: '${NavigationConstant.CREATE_SHOPPING_ITEM_ROUTE}/:listId',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          final listName =
              state.uri.queryParameters['name'] ?? 'Course inconnue';
          final week =
              int.tryParse(state.uri.queryParameters['week'] ?? '0') ?? 0;

          return CreateShoppingItemScreen(
            listId: listId,
            listName: listName,
            weekNumber: week,
          );
        },
        redirect: (context, state) => RoleGuard().checkAccess(),
      ),
      GoRoute(
        path:
            '${NavigationConstant.CREATE_SHOPPING_ITEM_ROUTE}/:listId/finalize',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          final listName =
              state.uri.queryParameters['name'] ?? 'Course inconnue';
          final week =
              int.tryParse(state.uri.queryParameters['week'] ?? '0') ?? 0;

          return FinalizeShoppingItemScreen(
            listId: listId,
            listName: listName,
            weekNumber: week,
          );
        },
        redirect: (context, state) => RoleGuard().checkAccess(),
      ),
      GoRoute(
        path: NavigationConstant.NOTIFICATION_ROUTE,
        builder: (context, state) {
          return NotificationsScreen();
        },
        redirect: (context, state) => RoleGuard().checkAccess(),
      ),
    ],
  );
}
