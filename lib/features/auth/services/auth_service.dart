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

  Future<RegisterResponse> login(LoginRequest request) async {
    final response = await _apiClient.postNoAuth(
      ApiConfig.login,
      body: request.toJson(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
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

  Future<void> logout() async {
    _currentUser = null;
    await _tokenStorage.clear();
  }
}