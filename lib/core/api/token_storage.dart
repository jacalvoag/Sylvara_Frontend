// lib/core/api/token_storage.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_storage_web.dart' if (dart.library.io) 'token_storage_stub.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userRoleKey = 'user_role';

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      webWrite(key, value);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      return webRead(key);
    }
    return await _storage.read(key: key);
  }

  Future<void> _deleteAll() async {
    if (kIsWeb) {
      webDelete(_accessTokenKey);
      webDelete(_refreshTokenKey);
      webDelete(_userRoleKey);
    } else {
      await _storage.deleteAll();
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    await _write(_accessTokenKey, accessToken);
    await _write(_refreshTokenKey, refreshToken);
    await _write(_userRoleKey, role);
  }

  Future<String?> getAccessToken() => _read(_accessTokenKey);
  Future<String?> getRefreshToken() => _read(_refreshTokenKey);
  Future<String?> getUserRole() => _read(_userRoleKey);

  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'ADMIN';
  }

  Future<void> clear() => _deleteAll();

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}