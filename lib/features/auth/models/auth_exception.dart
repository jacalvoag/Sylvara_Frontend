class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException({
    required this.message,
    this.statusCode,
  });

  // Crear desde JSON de error (400, 409, 500)
  factory AuthException.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return AuthException(
      message: json['message'] as String? ?? 'Error desconocido',
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'AuthException [$statusCode]: $message';
    }
    return 'AuthException: $message';
  }

  // Métodos auxiliares para identificar el tipo de error
  bool get isBadRequest => statusCode == 400;
  bool get isConflict => statusCode == 409;
  bool get isServerError => statusCode == 500;
}
