import 'user.dart';

class RegisterResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  RegisterResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  // Crear desde JSON (respuesta 201)
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}
