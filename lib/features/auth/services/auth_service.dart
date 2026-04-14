import 'dart:convert';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';
import 'package:sylvara_frontend/core/api/token_storage.dart';
import 'package:sylvara_frontend/features/auth/models/models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _apiClient = ApiClient();
  final _tokenStorage = TokenStorage();

  User? _currentUser;

  User? get currentUser => _currentUser;
  Future<bool> get isAuthenticated => _tokenStorage.hasTokens();

  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _apiClient.postNoAuth(
      ApiConfig.register,
      body: request.toJson(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final registerResponse = RegisterResponse.fromJson(data);

      await _tokenStorage.saveTokens(
        accessToken: registerResponse.accessToken,
        refreshToken: registerResponse.refreshToken,
        role: registerResponse.user.role ?? 'USER',
      );

      _currentUser = registerResponse.user;
      return registerResponse;
    }

    throw AuthException.fromJson(data, statusCode: response.statusCode);
  }

  /// Retorna [RegisterResponse] si el login fue exitoso sin 2FA,
  /// o lanza [TwoFactorRequiredException] si se requiere verificación.
  Future<RegisterResponse> login(LoginRequest request) async {
    final response = await _apiClient.postNoAuth(
      ApiConfig.login,
      body: request.toJson(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // El backend devuelve requiresTwoFactor cuando 2FA está activo
      if (data['requiresTwoFactor'] == true) {
        throw TwoFactorRequiredException(
          twoFactorToken: data['twoFactorToken'] as String,
        );
      }

      final loginResponse = RegisterResponse.fromJson(data);

      await _tokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        role: loginResponse.user.role ?? 'USER',
      );

      _currentUser = loginResponse.user;
      return loginResponse;
    }

    throw AuthException.fromJson(data, statusCode: response.statusCode);
  }

  Future<RegisterResponse> verifyTwoFactor({
    required String twoFactorToken,
    required String code,
  }) async {
    final response = await _apiClient.postWithToken(
      ApiConfig.twoFactorVerify,
      token: twoFactorToken,
      body: {'code': code},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final loginResponse = RegisterResponse.fromJson(data);

      await _tokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        role: loginResponse.user.role ?? 'USER',
      );

      _currentUser = loginResponse.user;
      return loginResponse;
    }

    throw AuthException.fromJson(data, statusCode: response.statusCode);
  }

  Future<bool> toggleTwoFactor({required bool enabled}) async {
    final response = await _apiClient.post(
      ApiConfig.twoFactorToggle,
      body: {'enabled': enabled},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['twoFactorEnabled'] as bool;
    }

    throw AuthException.fromJson(data, statusCode: response.statusCode);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _tokenStorage.clear();
  }
}

class TwoFactorRequiredException implements Exception {
  final String twoFactorToken;
  TwoFactorRequiredException({required this.twoFactorToken});
}