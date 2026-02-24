import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/auth/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _fechaNacimientoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleRegister() {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      // Aquí iría la lógica de registro
      print('Registro exitoso');
      print('Nombre: ${_nombreController.text}');
      print('Apellidos: ${_apellidosController.text}');
      print('Fecha de nacimiento: ${_fechaNacimientoController.text}');
      print('Correo: ${_correoController.text}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso'),
          backgroundColor: Color(0xFF0E3520),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Por favor, completa correctamente todos los campos';
      });
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Imagen de fondo
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/auth_background.jpg',
            height: 933,
          ),
          // Contenido
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  // Logo y título SYLVARA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo placeholder (círculo verde oscuro con icono)
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
                      const SizedBox(width: 8),
                      // Texto SYLVARA
                      const Text(
                        'SYLVARA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0E3520),
                          letterSpacing: 2.24,
                          fontFamily: 'Montserrat',
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 27),
                  // Contenedor del formulario
                  SizedBox(
                    width: 336,
                    child: Column(
                      children: [
                        // Header con glassmorphism
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
                                      text: 'Crea ',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0E3520),
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'una cuenta',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF0E3520),
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Formulario - posicionado sobre el header
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF0E3520),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                  // Campo: Nombre
                                  CustomTextField(
                                    label: 'Nombre',
                                    placeholder: 'Ej. Gilberto',
                                    controller: _nombreController,
                                    keyboardType: TextInputType.name,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa tu nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 23),
                                  // Campo: Apellidos
                                  CustomTextField(
                                    label: 'Apellidos',
                                    placeholder: 'Ej. Malaga',
                                    controller: _apellidosController,
                                    keyboardType: TextInputType.name,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa tus apellidos';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 23),
                                  // Campo: Fecha de nacimiento
                                  CustomTextField(
                                    label: 'Fecha de nacimiento',
                                    placeholder: 'Ej.  15/10/2000',
                                    controller: _fechaNacimientoController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor selecciona tu fecha de nacimiento';
                                      }
                                      return null;
                                    },
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _selectDate(context),
                                          child: const Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                            color: Color(0xFF0E3520),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 12,
                                          color: Color(0xFF0E3520),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 23),
                                  // Campo: Correo electrónico
                                  CustomTextField(
                                    label: 'Correo electronico',
                                    placeholder: 'Ej. malagaacos@gmail.com',
                                    controller: _correoController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa tu correo';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Ingresa un correo válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 23),
                                  // Campo: Contraseña
                                  CustomTextField(
                                    label: 'Contraseña',
                                    placeholder: 'Ej. malagaacos@gmail.com',
                                    controller: _contrasenaController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa una contraseña';
                                      }
                                      if (value.length < 6) {
                                        return 'La contraseña debe tener al menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 23),
                                  // Campo: Confirmar contraseña
                                  CustomTextField(
                                    label: 'Confirmar contraseña',
                                    placeholder: 'Ej. malagaacos@gmail.com',
                                    controller: _confirmarContrasenaController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor confirma tu contraseña';
                                      }
                                      if (value != _contrasenaController.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Advertencia (dentro del contenedor principal pero fuera del formulario)
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
                                
                                // Botones
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Botón Cancelar
                                    GestureDetector(
                                      onTap: _handleCancel,
                                      child: Container(
                                        width: 129,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFF0E3520),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0E3520),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // Botón Aceptar
                                    GestureDetector(
                                      onTap: _handleRegister,
                                      child: Container(
                                        width: 129,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0E3520),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Aceptar',
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
