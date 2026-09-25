import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'jwt_refresh_token';
  static const _expiresAtKey = 'jwt_expires_at';
  static const _userDataKey = 'cached_user_data';

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    int? expiresAt,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (expiresAt != null) {
      await _storage.write(key: _expiresAtKey, value: expiresAt.toString());
    }
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<int?> getExpiresAt() async {
    final val = await _storage.read(key: _expiresAtKey);
    return val != null ? int.tryParse(val) : null;
  }

  static Future<void> saveUserData(Map<String, dynamic> userJson) async {
    await _storage.write(key: _userDataKey, value: jsonEncode(userJson));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final val = await _storage.read(key: _userDataKey);
    if (val != null && val.isNotEmpty) {
      try {
        return jsonDecode(val) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiresAtKey);
    await _storage.delete(key: _userDataKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
