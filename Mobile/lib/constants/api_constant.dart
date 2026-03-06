// ignore_for_file: constant_identifier_names

class ApiConstant {
  // Timeouts
  static const Duration CONNECT_TIMEOUT = Duration(seconds: 30);
  static const Duration RECEIVE_TIMEOUT = Duration(seconds: 30);
  static const Duration SEND_TIMEOUT = Duration(seconds: 30);

  // Headers
  static const Map<String, String> HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // Endpoints
  static const String LOGIN_ENDPOINT = '/auth/login';
  static const String REGISTER_ENDPOINT = '/auth/register';
  static const String GET_USER_INFO_ENDPOINT = '/user/me';
  static const String SHOPPING_ITEMS_ENDPOINT = '/shopping-items';
  static const String SHOPPING_LISTS_ENDPOINT = '/shopping-lists';
  static const String PREDICT_QUANTITY_ENDPOINT = '/shopping-lists';
  static const String SHOPPING_LISTS_GENERATE_ENDPOINT =
      '$SHOPPING_LISTS_ENDPOINT/generate';
  static const String PREDICT_QUANTITY = '/predict/quantite';
  static const String PREDICT_CONSERVATION = '/predict/conservation';
}
