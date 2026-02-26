import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/auth/models/models.dart';
import 'package:sylvara_frontend/features/auth/services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Manejar el inicio de sesión
  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos correctamente';
        _isLoading = false;
      });
      return;
    }

    try {
      // Crear request según el contrato del backend
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Llamar al servicio de login
      final response = await _authService.login(request);

      if (!mounted) return;

      // Login exitoso (200)
      print('✅ Login exitoso');
      print('Usuario: ${response.user.fullName}');
      print('AccessToken: ${response.accessToken}');
      print('RefreshToken: ${response.refreshToken}');

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido, ${response.user.name}!'),
          backgroundColor: const Color(0xFF0E3520),
          duration: const Duration(seconds: 3),
        ),
      );

      // TODO: Navegar a la pantalla principal
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomeScreen()),
      // );

    } on AuthException catch (e) {
      // Manejar errores 400, 401, 500
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      
      print('❌ Error de autenticación [${e.statusCode}]: ${e.message}');
      
    } catch (e) {
      // Manejar otros errores inesperados
      setState(() {
        _errorMessage = 'Error inesperado. Por favor intenta de nuevo';
        _isLoading = false;
      });
      
      print('❌ Error inesperado: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/auth_background.jpg',
            height: 933,
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  
                  // Logo SYLVARA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logos/sylvara_logo.png',
                        width: 50,
                        height: 54,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.eco,
                            size: 50,
                            color: Color(0xFF0E3520),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SYLVARA',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0E3520),
                          letterSpacing: 2.24,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 27),
                  
                  // Form container
                  SizedBox(
                    width: 336,
                    child: Column(
                      children: [
                        // Glassmorphism header
                        Container(
                          width: 336,
                          height: 224,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCFFFD).withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 13),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Inicia ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0E3520),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'sesión',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 19,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF0E3520),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Main form container
                        Transform.translate(
                          offset: const Offset(0, -44),
                          child: Container(
                            width: 336,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Fields container
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 23,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF0E3520),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(29),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // Email field
                                        CustomTextField(
                                          label: 'Correo electronico',
                                          placeholder: 'Ej. malagaacos@gmail.com',
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'El correo es requerido';
                                            }
                                            final emailRegex = RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                            );
                                            if (!emailRegex.hasMatch(value)) {
                                              return 'Correo inválido';
                                            }
                                            return null;
                                          },
                                        ),
                                        
                                        const SizedBox(height: 23),
                                        
                                        // Password field
                                        CustomTextField(
                                          label: 'Contraseña',
                                          placeholder: '••••••••',
                                          controller: _passwordController,
                                          obscureText: true,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'La contraseña es requerida';
                                            }
                                            if (value.length < 6) {
                                              return 'Mínimo 6 caracteres';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Warning message area (fuera del formulario pero dentro del contenedor principal)
                                if (_errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.warning,
                                          color: Color(0xFFAE0000),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFAE0000),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                SizedBox(height: _errorMessage != null ? 16 : 0),
                                
                                // Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Cancel button
                                    GestureDetector(
                                      onTap: _isLoading ? null : _handleCancel,
                                      child: Container(
                                        width: 129,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _isLoading 
                                                ? Colors.grey 
                                                : const Color(0xFF0E3520),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _isLoading 
                                                  ? Colors.grey 
                                                  : const Color(0xFF0E3520),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // Accept button
                                    GestureDetector(
                                      onTap: _isLoading ? null : _handleLogin,
                                      child: Container(
                                        width: 129,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: _isLoading 
                                              ? Colors.grey 
                                              : const Color(0xFF0E3520),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  'Aceptar',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFF1F5F9),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
