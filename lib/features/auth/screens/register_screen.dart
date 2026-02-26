import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/auth/models/models.dart';
import 'package:sylvara_frontend/features/auth/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  // Controladores para los campos (nombres coinciden con el JSON del backend)
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Seleccionar fecha de nacimiento
  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0E3520),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0E3520),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Formatear a YYYY-MM-DD según el contrato del backend
      final formattedDate = 
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      setState(() {
        _birthdayController.text = formattedDate;
      });
    }
  }

  /// Manejar el registro
  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Por favor, completa correctamente todos los campos';
        _isLoading = false;
      });
      return;
    }

    // Validar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
        _isLoading = false;
      });
      return;
    }

    try {
      // Crear request según el contrato del backend
      final request = RegisterRequest(
        name: _nameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        birthday: _birthdayController.text.trim(), // Formato YYYY-MM-DD
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Llamar al servicio de registro
      final response = await _authService.register(request);

      if (!mounted) return;

      // Registro exitoso (201)
      print('✅ Registro exitoso');
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
      // Manejar errores 400, 409, 500
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

  /// Cancelar registro
  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/FondoAuth.png',
            height: 612,
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo SYLVARA
                      Container(
                        width: 50,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0E3520),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      
                      // Título "Regístrate"
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Regís',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                            TextSpan(
                              text: 'trate',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content with form
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Glassmorphism header
                        Container(
                          width: double.infinity,
                          height: 200,
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
                            padding: const EdgeInsets.only(left: 84, top: 50),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Completa ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0E3520),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'tus datos',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 22,
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
                        
                        // Form container
                        Transform.translate(
                          offset: const Offset(0, -141),
                          child: Container(
                            width: 336,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 28,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre
                                  CustomTextField(
                                    label: 'Nombre',
                                    placeholder: 'Ej. Gilberto',
                                    controller: _nameController,
                                    keyboardType: TextInputType.name,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa tu nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Apellidos
                                  CustomTextField(
                                    label: 'Apellidos',
                                    placeholder: 'Ej. Malaga',
                                    controller: _lastnameController,
                                    keyboardType: TextInputType.name,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa tus apellidos';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Fecha de nacimiento
                                  CustomTextField(
                                    label: 'Fecha de nacimiento',
                                    placeholder: 'YYYY-MM-DD',
                                    controller: _birthdayController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor selecciona tu fecha de nacimiento';
                                      }
                                      // Validar formato YYYY-MM-DD
                                      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                                      if (!dateRegex.hasMatch(value)) {
                                        return 'Formato inválido (YYYY-MM-DD)';
                                      }
                                      return null;
                                    },
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _selectBirthday(context),
                                          child: const Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                            color: Color(0xFF0E3520),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Correo electrónico
                                  CustomTextField(
                                    label: 'Correo electrónico',
                                    placeholder: 'Ej. malagaacos@gmail.com',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa tu correo';
                                      }
                                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Ingresa un correo válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Contraseña
                                  CustomTextField(
                                    label: 'Contraseña',
                                    placeholder: 'Mínimo 6 caracteres',
                                    controller: _passwordController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa una contraseña';
                                      }
                                      if (value.length < 6) {
                                        return 'Mínimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Confirmar contraseña
                                  CustomTextField(
                                    label: 'Confirmar contraseña',
                                    placeholder: 'Repite tu contraseña',
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor confirma tu contraseña';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Advertencia de errores
                                  if (_errorMessage != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      margin: const EdgeInsets.only(bottom: 27),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.warning,
                                            color: Color(0xFFAE0000),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
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
                                  
                                  // Botones
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Botón Cancelar
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
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _isLoading 
                                                  ? Colors.grey 
                                                  : const Color(0xFF0E3520),
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      
                                      // Botón Registrarse
                                      GestureDetector(
                                        onTap: _isLoading ? null : _handleRegister,
                                        child: Container(
                                          width: 129,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: _isLoading 
                                                ? Colors.grey 
                                                : const Color(0xFF0E3520),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
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
                                                  'Registrarse',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFF1F5F9),
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
