import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access-token';
  static const String _refreshTokenKey = 'refresh-token';

  static Future<void> saveAccessToken(String? token) async {
    if (token != null) {
      await storage.write(key: _accessTokenKey, value: token);
    }
  }

  static Future<void> saveRefreshToken(String? token) async {
    if (token != null) {
      await storage.write(key: _refreshTokenKey, value: token);
    }
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }

  static Future<void> deleteTokens() async {
    await storage.deleteAll();
  }
}