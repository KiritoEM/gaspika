import 'package:gaspika_mobile/models/auth_model.dart';

class RoleGuard {
  final _authModel = AuthModel();

  // Check access to a route
  Future<String?> checkAccess() async {
    if (await isUserAuthentificated()) {
      return Future.value(null);
    } else {
      return Future.value('/login');
    }
  }

  // Redirect if user is already authenticated
  Future<String?> redirectIfAuthentificated() async {
    if (await isUserAuthentificated()) {
      return Future.value('/home');
    } else {
      return Future.value(null);
    }
  }

  // Check if user is authenticated based on role[TODO: implement role check]
  Future<bool> isUserAuthentificated() => _authModel.isAuthenticated();
}
