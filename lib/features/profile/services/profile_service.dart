import 'package:sylvara_frontend/features/profile/models/profile_models.dart';

/// Servicio para gestionar el perfil del usuario
/// 
/// Este servicio maneja las operaciones CRUD del perfil:
/// - GET /profile: Obtener datos del perfil
/// - PATCH /profile: Actualizar datos del perfil
/// - PUT /profile/password: Cambiar contraseña
/// - DELETE /profile: Eliminar cuenta
class ProfileService {
  // Singleton pattern para mantener una única instancia
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  // Simulación de datos del usuario en memoria
  UserProfile? _cachedProfile;

  /// Obtener el perfil del usuario (GET /profile)
  /// 
  /// Respuestas esperadas:
  /// - 200: Retorna los datos del perfil
  /// - 401: Usuario no autenticado
  /// - 500: Error del servidor
  Future<UserProfile> getProfile() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.get(
    //   Uri.parse('https://api.sylvara.com/profile'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );
    // 
    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   _cachedProfile = UserProfile.fromJson(data);
    //   return _cachedProfile!;
    // } else if (response.statusCode == 401) {
    //   throw ProfileException(
    //     message: 'No autenticado',
    //     statusCode: 401,
    //   );
    // } else {
    //   final data = json.decode(response.body);
    //   throw ProfileException(
    //     message: data['message'] ?? 'Error al obtener el perfil',
    //     statusCode: response.statusCode,
    //   );
    // }

    // Datos mock simulando la respuesta del backend
    final Map<String, dynamic> mockResponse = {
      'user_id': 1,
      'user_name': 'Manuel',
      'user_lastname': 'Malaga',
      'user_birthday': '1995-06-15',
      'user_email': 'manuel.malaga@sylvara.com',
      'profile_picture_url': 'https://via.placeholder.com/150',
      'user_role': 'Administrador',
    };

    _cachedProfile = UserProfile.fromJson(mockResponse);
    print('👤 Perfil obtenido exitosamente: ${_cachedProfile!.userName} ${_cachedProfile!.userLastname}');
    
    return _cachedProfile!;
  }

  /// Actualizar el perfil del usuario (PATCH /profile)
  /// 
  /// Respuestas esperadas:
  /// - 200: Perfil actualizado exitosamente
  /// - 400: Datos inválidos
  /// - 401: Usuario no autenticado
  /// - 500: Error del servidor
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Validación de campos (400 - Bad Request)
    if (request.userName.isEmpty || request.userLastname.isEmpty) {
      throw ProfileException(
        message: 'El nombre y apellido son obligatorios',
        statusCode: 400,
      );
    }

    if (request.userName.length < 2) {
      throw ProfileException(
        message: 'El nombre debe tener al menos 2 caracteres',
        statusCode: 400,
      );
    }

    if (request.userLastname.length < 2) {
      throw ProfileException(
        message: 'El apellido debe tener al menos 2 caracteres',
        statusCode: 400,
      );
    }

    // Validación de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(request.userEmail)) {
      throw ProfileException(
        message: 'El email no es válido',
        statusCode: 400,
      );
    }

    // Validación de fecha de nacimiento (formato YYYY-MM-DD)
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(request.userBirthday)) {
      throw ProfileException(
        message: 'La fecha de nacimiento debe estar en formato YYYY-MM-DD',
        statusCode: 400,
      );
    }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.patch(
    //   Uri.parse('https://api.sylvara.com/profile'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: json.encode(request.toJson()),
    // );
    // 
    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   _cachedProfile = UserProfile.fromJson(data);
    //   return _cachedProfile!;
    // } else if (response.statusCode == 400) {
    //   final data = json.decode(response.body);
    //   throw ProfileException(
    //     message: data['message'] ?? 'Datos inválidos',
    //     statusCode: 400,
    //   );
    // } else if (response.statusCode == 401) {
    //   throw ProfileException(
    //     message: 'No autenticado',
    //     statusCode: 401,
    //   );
    // } else {
    //   final data = json.decode(response.body);
    //   throw ProfileException(
    //     message: data['message'] ?? 'Error al actualizar el perfil',
    //     statusCode: response.statusCode,
    //   );
    // }

    // Simular respuesta exitosa del backend
    final Map<String, dynamic> mockResponse = {
      'user_id': _cachedProfile?.userId ?? 1,
      'user_name': request.userName,
      'user_lastname': request.userLastname,
      'user_birthday': request.userBirthday,
      'user_email': request.userEmail,
      'profile_picture_url': request.profilePictureUrl,
      'user_role': _cachedProfile?.userRole ?? 'Administrador',
    };

    _cachedProfile = UserProfile.fromJson(mockResponse);
    print('✅ Perfil actualizado exitosamente: ${_cachedProfile!.userName} ${_cachedProfile!.userLastname}');
    
    return _cachedProfile!;
  }

  /// Cambiar la contraseña del usuario (PUT /profile/password)
  /// 
  /// Respuestas esperadas:
  /// - 200: Contraseña actualizada exitosamente
  /// - 400: Contraseña actual incorrecta o nueva contraseña inválida
  /// - 401: Usuario no autenticado
  /// - 500: Error del servidor
  Future<void> changePassword(UpdatePasswordRequest request) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Validación de campos (400 - Bad Request)
    if (request.currentPassword.isEmpty || request.newPassword.isEmpty) {
      throw ProfileException(
        message: 'Las contraseñas son obligatorias',
        statusCode: 400,
      );
    }

    // Validar longitud mínima de la nueva contraseña
    if (request.newPassword.length < 8) {
      throw ProfileException(
        message: 'La nueva contraseña debe tener al menos 8 caracteres',
        statusCode: 400,
      );
    }

    // Validar que la nueva contraseña tenga al menos una mayúscula, una minúscula y un número
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(request.newPassword);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(request.newPassword);
    final hasDigit = RegExp(r'[0-9]').hasMatch(request.newPassword);

    if (!hasUpperCase || !hasLowerCase || !hasDigit) {
      throw ProfileException(
        message: 'La nueva contraseña debe contener mayúsculas, minúsculas y números',
        statusCode: 400,
      );
    }

    // Simular validación de contraseña actual incorrecta (20% de probabilidad)
    // En producción, esto lo validará el backend
    // if (request.currentPassword != 'password123') {
    //   throw ProfileException(
    //     message: 'La contraseña actual es incorrecta',
    //     statusCode: 400,
    //   );
    // }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.put(
    //   Uri.parse('https://api.sylvara.com/profile/password'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: json.encode(request.toJson()),
    // );
    // 
    // if (response.statusCode == 200) {
    //   print('🔒 Contraseña actualizada exitosamente');
    //   return;
    // } else if (response.statusCode == 400) {
    //   final data = json.decode(response.body);
    //   throw ProfileException(
    //     message: data['message'] ?? 'Contraseña actual incorrecta',
    //     statusCode: 400,
    //   );
    // } else if (response.statusCode == 401) {
    //   throw ProfileException(
    //     message: 'No autenticado',
    //     statusCode: 401,
    //   );
    // } else {
    //   final data = json.decode(response.body);
    //   throw ProfileException(
    //     message: data['message'] ?? 'Error al cambiar la contraseña',
    //     statusCode: response.statusCode,
    //   );
    // }

    // Simular respuesta exitosa
    print('🔒 Contraseña actualizada exitosamente');
  }

  /// Eliminar la cuenta del usuario (DELETE /profile)
  /// 
  /// Respuestas esperadas:
  /// - 204: Cuenta eliminada exitosamente (No Content)
  /// - 401: Usuario no autenticado
  /// - 500: Error del servidor
  Future<void> deleteAccount() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 900));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.delete(
    //   Uri.parse('https://api.sylvara.com/profile'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );
    // 
    // if (response.statusCode == 204) {
    //   _cachedProfile = null;
    //   print('🗑️ Cuenta eliminada exitosamente');
    //   return;
    // } else if (response.statusCode == 401) {
    //   throw ProfileException(
    //     message: 'No autenticado',
    //     statusCode: 401,
    //   );
    // } else {
    //   final data = json.decode(response.body);
    //   throw ProfileException(
    //     message: data['message'] ?? 'Error al eliminar la cuenta',
    //     statusCode: response.statusCode,
    //   );
    // }

    // Simular respuesta exitosa (204 - No Content)
    _cachedProfile = null;
    print('🗑️ Cuenta eliminada exitosamente');
  }

  /// Limpiar la caché del perfil (útil para logout)
  void clearCache() {
    _cachedProfile = null;
    print('🧹 Caché del perfil limpiada');
  }

  /// Obtener el perfil en caché sin hacer petición a la API
  UserProfile? getCachedProfile() {
    return _cachedProfile;
  }
}
