import 'dart:convert';
import 'package:sylvara_frontend/features/auth/models/models.dart';

class AuthService {
  // Singleton pattern para mantener una única instancia
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Simulación de base de datos en memoria
  final List<Map<String, dynamic>> _mockUsers = [];
  
  // Tokens simulados (en producción, el backend los generaría)
  String? _currentAccessToken;
  String? _currentRefreshToken;
  User? _currentUser;

  // Getters para acceder a la sesión actual
  String? get accessToken => _currentAccessToken;
  String? get refreshToken => _currentRefreshToken;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentAccessToken != null && _currentUser != null;

  /// Registro de usuario (POST /auth/register)
  /// 
  /// Simula el comportamiento del backend:
  /// - 201: Registro exitoso con tokens y datos del usuario
  /// - 400: Datos inválidos
  /// - 409: Email ya registrado
  /// - 500: Error del servidor (simulado aleatoriamente)
  Future<RegisterResponse> register(RegisterRequest request) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    // Validación de campos (400 - Bad Request)
    if (request.name.isEmpty || 
        request.lastname.isEmpty || 
        request.birthday.isEmpty || 
        request.email.isEmpty || 
        request.password.isEmpty) {
      throw AuthException(
        message: 'Todos los campos son obligatorios',
        statusCode: 400,
      );
    }

    // Validar formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(request.email)) {
      throw AuthException(
        message: 'El formato del correo electrónico no es válido',
        statusCode: 400,
      );
    }

    // Validar longitud de contraseña
    if (request.password.length < 6) {
      throw AuthException(
        message: 'La contraseña debe tener al menos 6 caracteres',
        statusCode: 400,
      );
    }

    // Validar formato de fecha (YYYY-MM-DD)
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(request.birthday)) {
      throw AuthException(
        message: 'El formato de la fecha debe ser YYYY-MM-DD',
        statusCode: 400,
      );
    }

    // Verificar si el email ya existe (409 - Conflict)
    final existingUser = _mockUsers.firstWhere(
      (user) => user['email'] == request.email,
      orElse: () => {},
    );

    if (existingUser.isNotEmpty) {
      throw AuthException(
        message: 'El correo electrónico ya está registrado',
        statusCode: 409,
      );
    }

    // Simular error del servidor (500) - 5% de probabilidad
    // if (DateTime.now().millisecond % 20 == 0) {
    //   throw AuthException(
    //     message: 'Error interno del servidor. Por favor intenta más tarde',
    //     statusCode: 500,
    //   );
    // }

    // Registro exitoso (201 - Created)
    final now = DateTime.now();
    final userId = 'user_${_mockUsers.length + 1}_${now.millisecondsSinceEpoch}';
    
    final userData = {
      'id': userId,
      'name': request.name,
      'lastname': request.lastname,
      'birthday': request.birthday,
      'email': request.email,
      'password': request.password, // En producción, esto estaría hasheado
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    _mockUsers.add(userData);

    // Generar tokens mock
    final accessToken = _generateMockToken('access', userId);
    final refreshToken = _generateMockToken('refresh', userId);

    // Crear usuario sin la contraseña
    final user = User(
      id: userData['id'] as String,
      name: userData['name'] as String,
      lastname: userData['lastname'] as String,
      birthday: userData['birthday'] as String,
      email: userData['email'] as String,
      createdAt: DateTime.parse(userData['createdAt'] as String),
      updatedAt: DateTime.parse(userData['updatedAt'] as String),
    );

    // Guardar sesión actual
    _currentAccessToken = accessToken;
    _currentRefreshToken = refreshToken;
    _currentUser = user;

    print('✅ Usuario registrado exitosamente: ${user.fullName}');
    print('📧 Email: ${user.email}');
    print('🔑 Access Token: $accessToken');

    return RegisterResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  /// Login de usuario (POST /auth/login)
  /// Mock para futuro uso
  Future<RegisterResponse> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = _mockUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) {
      throw AuthException(
        message: 'Credenciales incorrectas',
        statusCode: 401,
      );
    }

    final accessToken = _generateMockToken('access', user['id'] as String);
    final refreshToken = _generateMockToken('refresh', user['id'] as String);

    final userData = User(
      id: user['id'] as String,
      name: user['name'] as String,
      lastname: user['lastname'] as String,
      birthday: user['birthday'] as String,
      email: user['email'] as String,
      createdAt: DateTime.parse(user['createdAt'] as String),
      updatedAt: DateTime.parse(user['updatedAt'] as String),
    );

    _currentAccessToken = accessToken;
    _currentRefreshToken = refreshToken;
    _currentUser = userData;

    return RegisterResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: userData,
    );
  }

  /// Cerrar sesión
  void logout() {
    _currentAccessToken = null;
    _currentRefreshToken = null;
    _currentUser = null;
    print('Sesión cerrada');
  }

  /// Generar token mock
  String _generateMockToken(String type, String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = base64Encode(utf8.encode('$type:$userId:$timestamp'));
    return 'mock_${type}_token_$payload';
  }

  /// Obtener todos los usuarios mock (solo para desarrollo)
  List<Map<String, dynamic>> getAllMockUsers() {
    return List.unmodifiable(_mockUsers);
  }

  /// Limpiar todos los usuarios mock (solo para desarrollo/testing)
  void clearAllMockUsers() {
    _mockUsers.clear();
    logout();
    print('Base de datos mock limpiada');
  }
}
