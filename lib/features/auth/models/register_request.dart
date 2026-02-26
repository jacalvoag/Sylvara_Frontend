class RegisterRequest {
  final String name;
  final String lastname;
  final String birthday; // Formato: YYYY-MM-DD
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.lastname,
    required this.birthday,
    required this.email,
    required this.password,
  });

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastname': lastname,
      'birthday': birthday,
      'email': email,
      'password': password,
    };
  }

  // Crear desde JSON (si es necesario)
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      birthday: json['birthday'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}
