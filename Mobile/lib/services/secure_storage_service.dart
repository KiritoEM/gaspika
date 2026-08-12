import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // singleton
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future write(String key, dynamic value) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future update(String key, dynamic value) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future clear() async {
    await _storage.deleteAll();
  }
}
