import 'dart:convert';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';
import 'package:sylvara_frontend/features/profile/models/profile_models.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final _apiClient = ApiClient();
  UserProfile? _cachedProfile;

  Future<UserProfile> getProfile() async {
    final response = await _apiClient.get(ApiConfig.profile);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _cachedProfile = UserProfile.fromJson(data);
      return _cachedProfile!;
    } else if (response.statusCode == 401) {
      throw ProfileException(message: 'No autenticado', statusCode: 401);
    } else {
      throw ProfileException(
        message: data['message'] ?? 'Error al obtener el perfil',
        statusCode: response.statusCode,
      );
    }
  }

  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    final response = await _apiClient.patch(
      ApiConfig.profile,
      body: request.toJson(),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _cachedProfile = UserProfile.fromJson(data);
      return _cachedProfile!;
    } else {
      throw ProfileException(
        message: data['message'] ?? 'Error al actualizar el perfil',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> changePassword(UpdatePasswordRequest request) async {
    final response = await _apiClient.put(
      ApiConfig.profilePassword,
      body: request.toJson(),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw ProfileException(
        message: data['message'] ?? 'Error al cambiar la contraseña',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteAccount() async {
    final response = await _apiClient.delete(ApiConfig.profile);

    if (response.statusCode != 204) {
      final data = jsonDecode(response.body);
      throw ProfileException(
        message: data['message'] ?? 'Error al eliminar la cuenta',
        statusCode: response.statusCode,
      );
    }
    _cachedProfile = null;
  }

  void clearCache() => _cachedProfile = null;
  UserProfile? getCachedProfile() => _cachedProfile;
}