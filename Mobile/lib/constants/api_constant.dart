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
  };

  // Endpoints
  static const String LOGIN_ENDPOINT = '/auth/login';
  static const String REGISTER_ENDPOINT = '/auth/register';
}
