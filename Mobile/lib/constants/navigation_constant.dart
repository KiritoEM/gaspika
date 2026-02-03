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
  static const String FINALIZE_CREATE_SHOPPING_ITEM_ROUTE =
      '$CREATE_SHOPPING_ITEM_ROUTE/finalize';

  // Bottom Navigation Routes
  static const List<Map<String, dynamic>> BOTTOM_NAVIGATION_ROUTES = [
    {'route': HOME_ROUTE, 'label': 'Accueil', 'icon': 'assets/icons/home.svg'},
    {
      'route': HOME_ROUTE,
      'label': 'Liste des courses',
      'icon': 'assets/icons/shopping-list.svg',
    },
    {'route': HOME_ROUTE, 'label': 'Profil', 'icon': 'assets/icons/person.svg'},
  ];
}
