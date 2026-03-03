/// Modelo para el perfil del usuario (GET /profile)
class UserProfile {
  final int userId;
  final String userName;
  final String userLastname;
  final String userBirthday;
  final String userEmail;
  final String profilePictureUrl;
  final String userRole;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.userLastname,
    required this.userBirthday,
    required this.userEmail,
    required this.profilePictureUrl,
    required this.userRole,
  });

  /// Crear una instancia desde JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      userLastname: json['user_lastname'] as String,
      userBirthday: json['user_birthday'] as String,
      userEmail: json['user_email'] as String,
      profilePictureUrl: json['profile_picture_url'] as String,
      userRole: json['user_role'] as String,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_lastname': userLastname,
      'user_birthday': userBirthday,
      'user_email': userEmail,
      'profile_picture_url': profilePictureUrl,
      'user_role': userRole,
    };
  }

  /// Crear una copia con campos modificados
  UserProfile copyWith({
    int? userId,
    String? userName,
    String? userLastname,
    String? userBirthday,
    String? userEmail,
    String? profilePictureUrl,
    String? userRole,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userLastname: userLastname ?? this.userLastname,
      userBirthday: userBirthday ?? this.userBirthday,
      userEmail: userEmail ?? this.userEmail,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      userRole: userRole ?? this.userRole,
    );
  }
}

/// Modelo para actualizar el perfil (PATCH /profile)
class UpdateProfileRequest {
  final String userName;
  final String userLastname;
  final String userBirthday;
  final String userEmail;
  final String profilePictureUrl;

  UpdateProfileRequest({
    required this.userName,
    required this.userLastname,
    required this.userBirthday,
    required this.userEmail,
    required this.profilePictureUrl,
  });

  /// Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'user_lastname': userLastname,
      'user_birthday': userBirthday,
      'user_email': userEmail,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

/// Modelo para cambiar la contraseña (PUT /profile/password)
class UpdatePasswordRequest {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  /// Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}

/// Excepción personalizada para errores de perfil
class ProfileException implements Exception {
  final String message;
  final int statusCode;

  ProfileException({
    required this.message,
    this.statusCode = 500,
  });

  @override
  String toString() {
    return 'ProfileException($statusCode): $message';
  }
}
