// ignore_for_file: constant_identifier_names

class NavigationConstant {
  // Routes Name
  static const String DEFAULT_ROUTE = '/';
  static const String LOGIN_ROUTE = '/login';
  static const String REGISTER_ROUTE = '/register';
  static const String HOME_ROUTE = '/home';
  static const String SHOPPING_LISTS_ROUTE = '/shopping-list';
  static const String SHOPPING_LISTS_ITEMS_ROUTE = '/shopping-list-items';
  static const String CREATE_SHOPPING_ITEM_ROUTE = '/create-shopping-item';
  static const String NOTIFICATION_ROUTE = '/notification';
  static const String SETTINGS_ROUTE = '/settings';
  static const String SETTINGS_ACCOUNT_ROUTE = '/settings/account';
  static const String SETTINGS_SECURITY_ROUTE = '/settings/security';
  static const String SETTINGS_NOTIFICATIONS_ROUTE = '/settings/notifications';

  // Bottom Navigation Routes
  static const List<Map<String, dynamic>> BOTTOM_NAVIGATION_ROUTES = [
    {
      'route': HOME_ROUTE,
      'label': 'Accueil',
      'icon': 'assets/icons/home.svg',
      'icon_width': 24.0,
    },
    {
      'route': SHOPPING_LISTS_ROUTE,
      'label': 'Listes de courses',
      'icon': 'assets/icons/shopping-list.svg',
      'icon_width': 28.0,
    },
    {
      'route': SETTINGS_ROUTE,
      'label': 'Mon compte',
      'icon': 'assets/icons/person.svg',
      'icon_width': 24.0,
    },
  ];
}
