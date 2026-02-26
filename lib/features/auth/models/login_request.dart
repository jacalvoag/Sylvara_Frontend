class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  // Crear desde JSON (si es necesario)
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}
