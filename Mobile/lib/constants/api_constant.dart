// ignore_for_file: constant_identifier_names

class ApiConstant {
  // Timeouts
  static const Duration CONNECT_TIMEOUT = Duration(seconds: 35);
  static const Duration RECEIVE_TIMEOUT = Duration(seconds: 35);
  static const Duration SEND_TIMEOUT = Duration(seconds: 35);

  // Headers
  static const Map<String, String> HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // Endpoints
  static const String LOGIN_ENDPOINT = '/auth/login';
  static const String REGISTER_ENDPOINT = '/auth/register';
  static const String USER_INFO_ENDPOINT = '/user';
  static const String USER_ME_ENDPOINT = '$USER_INFO_ENDPOINT/me';
  static const String USER_LOGOUT_ENDPOINT = '$USER_INFO_ENDPOINT/logout';
  static const String USER_PASSWORD_ENDPOINT = '$USER_ME_ENDPOINT/password';
  static const String USER_NOTIFICATION_PREFERENCES_ENDPOINT =
      '$USER_ME_ENDPOINT/notification-preferences';
  static const String SHOPPING_ITEMS_ENDPOINT = '/shopping-items';
  static const String SHOPPING_LISTS_ENDPOINT = '/shopping-lists';
  static const String PREDICT_QUANTITY_ENDPOINT = '/shopping-lists';
  static const String SHOPPING_LISTS_GENERATE_ENDPOINT =
      '$SHOPPING_LISTS_ENDPOINT/generate';
  static const String PREDICT_QUANTITY = '/predict/quantite';
  static const String PREDICT_CONSERVATION = '/predict/conservation';
  static const String CATEGORIES_ENDPOINT = '/categories';
  static const String DEVICE_ENDPOINT = '/devices';
  static const String NOTIFICATION_ENDPOINT = '/notifications';
}
