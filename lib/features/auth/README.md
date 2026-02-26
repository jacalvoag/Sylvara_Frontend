# Sistema de Registro - Sylvara Frontend

## 📋 Implementación basada en el contrato del backend

### Estructura de archivos

```
lib/features/auth/
├── models/
│   ├── register_request.dart      # Modelo de request para POST /auth/register
│   ├── register_response.dart     # Modelo de respuesta exitosa (201)
│   ├── user.dart                  # Modelo de usuario
│   ├── auth_exception.dart        # Excepción personalizada para errores
│   └── models.dart                # Barrel file
├── services/
│   └── auth_service.dart          # Servicio mock para autenticación
└── screens/
    ├── register_screen.dart       # Pantalla de registro
    └── screens.dart               # Barrel file
```

---

## 🔌 Contrato del Backend

### Request (POST /auth/register)

**Campos requeridos:**
```json
{
  "name": "String",
  "lastname": "String", 
  "birthday": "String (YYYY-MM-DD)",
  "email": "String",
  "password": "String"
}
```

### Respuestas

#### ✅ 201 Created - Registro exitoso
```json
{
  "accessToken": "string",
  "refreshToken": "string",
  "user": {
    "id": "string",
    "name": "string",
    "lastname": "string",
    "birthday": "string",
    "email": "string",
    "createdAt": "ISO8601 string",
    "updatedAt": "ISO8601 string"
  }
}
```

#### ❌ 400 Bad Request - Datos inválidos
```json
{
  "message": "Todos los campos son obligatorios"
}
```

#### ❌ 409 Conflict - Email ya registrado
```json
{
  "message": "El correo electrónico ya está registrado"
}
```

#### ❌ 500 Internal Server Error
```json
{
  "message": "Error interno del servidor"
}
```

---

## 🏗️ Modelos Implementados

### RegisterRequest
```dart
class RegisterRequest {
  final String name;
  final String lastname;
  final String birthday;  // Formato: YYYY-MM-DD
  final String email;
  final String password;
  
  Map<String, dynamic> toJson() { ... }
  factory RegisterRequest.fromJson(Map<String, dynamic> json) { ... }
}
```

### RegisterResponse
```dart
class RegisterResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  
  factory RegisterResponse.fromJson(Map<String, dynamic> json) { ... }
}
```

### User
```dart
class User {
  final String id;
  final String name;
  final String lastname;
  final String birthday;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  String get fullName => '$name $lastname';
}
```

### AuthException
```dart
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  
  factory AuthException.fromJson(Map<String, dynamic> json, {int? statusCode}) { ... }
  
  bool get isBadRequest => statusCode == 400;
  bool get isConflict => statusCode == 409;
  bool get isServerError => statusCode == 500;
}
```

---

## 🔧 Servicio de Autenticación (Mock)

### AuthService

**Patrón Singleton** - Una única instancia en toda la aplicación.

```dart
final authService = AuthService();
```

#### Métodos principales:

##### 1. register()
```dart
Future<RegisterResponse> register(RegisterRequest request) async
```

Simula el comportamiento del backend:
- **201**: Registro exitoso, retorna tokens y datos del usuario
- **400**: Valida campos vacíos, formato de email, longitud de contraseña, formato de fecha
- **409**: Verifica si el email ya está registrado
- **500**: Simula errores del servidor (opcional)

##### 2. login() 
```dart
Future<RegisterResponse> login(String email, String password) async
```

##### 3. logout()
```dart
void logout()
```

##### Getters de sesión:
- `accessToken`: Token de acceso actual
- `refreshToken`: Token de refresh actual
- `currentUser`: Usuario autenticado
- `isAuthenticated`: Estado de autenticación

---

## 🎨 RegisterScreen

### Características implementadas:

✅ **6 campos de formulario** con nombres que coinciden con el JSON:
- `name` (Nombre)
- `lastname` (Apellidos)
- `birthday` (Fecha de nacimiento - selector con formato YYYY-MM-DD)
- `email` (Correo electrónico)
- `password` (Contraseña)
- Confirmación de contraseña (validación local)

✅ **Validaciones:**
- Campos obligatorios
- Formato de email válido
- Longitud mínima de contraseña (6 caracteres)
- Formato de fecha YYYY-MM-DD
- Coincidencia de contraseñas

✅ **Manejo de errores:**
- Muestra el mensaje de error del backend en la interfaz
- Área de advertencias con ícono y texto rojo
- Estado de carga con spinner

✅ **Integración con AuthService:**
- Crea `RegisterRequest` con nombres exactos del contrato
- Maneja respuestas 201, 400, 409, 500
- Captura y muestra el `message` de `AuthException`

---

## 🚀 Uso

### Ejemplo de registro:

```dart
import 'package:sylvara_frontend/features/auth/models/models.dart';
import 'package:sylvara_frontend/features/auth/services/auth_service.dart';

final authService = AuthService();

try {
  final request = RegisterRequest(
    name: 'Gilberto',
    lastname: 'Malaga',
    birthday: '2000-10-15',
    email: 'gilberto@example.com',
    password: 'securepass123',
  );
  
  final response = await authService.register(request);
  
  print('Usuario registrado: ${response.user.fullName}');
  print('Access Token: ${response.accessToken}');
  print('Refresh Token: ${response.refreshToken}');
  
} on AuthException catch (e) {
  // Manejar errores 400, 409, 500
  print('Error: ${e.message}');
  
  if (e.isBadRequest) {
    // Datos inválidos
  } else if (e.isConflict) {
    // Email ya registrado
  } else if (e.isServerError) {
    // Error del servidor
  }
}
```

---

## 🔄 Transición a Backend Real

Cuando esté listo el backend, solo necesitas:

1. **Instalar paquete HTTP:**
```yaml
dependencies:
  http: ^1.2.0
```

2. **Actualizar AuthService:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<RegisterResponse> register(RegisterRequest request) async {
  final response = await http.post(
    Uri.parse('https://api.sylvara.com/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(request.toJson()),
  );

  if (response.statusCode == 201) {
    return RegisterResponse.fromJson(jsonDecode(response.body));
  } else {
    final error = jsonDecode(response.body);
    throw AuthException.fromJson(error, statusCode: response.statusCode);
  }
}
```

3. **Los modelos y la UI permanecen sin cambios** ✨

---

## 📝 Notas importantes

- **Nombres de variables:** Todos coinciden exactamente con el JSON del backend
- **Formato de fecha:** YYYY-MM-DD (ISO 8601)
- **Gestión de sesión:** AuthService mantiene tokens y usuario actual
- **Base de datos mock:** Lista en memoria para desarrollo/testing
- **Logs de desarrollo:** Prints informativos para debugging

---

## 🧪 Testing

El servicio mock incluye métodos de utilidad:

```dart
// Ver todos los usuarios registrados
authService.getAllMockUsers();

// Limpiar base de datos mock
authService.clearAllMockUsers();
```

---

## 📱 Pantallas

Actualmente implementadas:
- ✅ RegisterScreen
- 🔜 LoginScreen
- 🔜 ProfileScreen

---

**Autor:** Sistema de Autenticación Sylvara  
**Fecha:** 2026-02-26  
**Status:** ✅ Completamente funcional con mock
