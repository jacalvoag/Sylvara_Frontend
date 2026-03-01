import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  String? _errorMessage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos del usuario desde sesión
    _loadUserData();
  }

  void _loadUserData() {
    // TODO: Cargar datos reales del usuario desde el backend/sesión
    setState(() {
      _nombreController.text = 'Gilberto';
      _apellidosController.text = 'Malaga';
      _fechaNacimientoController.text = '15/10/2000';
      _correoController.text = 'malagaacos@gmail.com';
    });
  }

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
    if (!_isEditing) return;
    
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

  void _handleEdit() {
    setState(() {
      _errorMessage = null;
      _isEditing = true;
    });

    if (_formKey.currentState!.validate()) {
      // TODO: Implementar lógica de actualización de perfil
      print('Actualizando perfil...');
      print('Nombre: ${_nombreController.text}');
      print('Apellidos: ${_apellidosController.text}');
      print('Fecha de nacimiento: ${_fechaNacimientoController.text}');
      print('Correo: ${_correoController.text}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: Color(0xFF0E3520),
        ),
      );
      
      setState(() {
        _isEditing = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Por favor, completa correctamente todos los campos';
      });
    }
  }

  void _handleCancel() {
    setState(() {
      _isEditing = false;
      _errorMessage = null;
      _contrasenaController.clear();
      _confirmarContrasenaController.clear();
    });
    _loadUserData();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implementar lógica de logout
                Navigator.of(context).pop();
                // Navegar a login screen
              },
              child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _handleImageUpload() {
    if (!_isEditing) return;
    
    // TODO: Implementar lógica de subida de imagen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de subida de imagen próximamente'),
        backgroundColor: Color(0xFF0E3520),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background image
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/FodoHome.png',
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
                      
                      // Título "Mis Perfil"
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Mis',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                            TextSpan(
                              text: ' Perfil',
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
                                      text: 'Configura ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0E3520),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'tú cuenta',
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
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 28,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
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
                                    controller: _nombreController,
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
                                    controller: _apellidosController,
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
                                          onTap: _isEditing ? () => _selectDate(context) : null,
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
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Correo electrónico
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
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Contraseña
                                  CustomTextField(
                                    label: 'Contraseña',
                                    placeholder: 'Ej. malagaacos@gmail.com',
                                    controller: _contrasenaController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (_isEditing && value != null && value.isNotEmpty) {
                                        if (value.length < 6) {
                                          return 'La contraseña debe tener al menos 6 caracteres';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Confirmar contraseña
                                  CustomTextField(
                                    label: 'Confirmar contraseña',
                                    placeholder: 'Ej. malagaacos@gmail.com',
                                    controller: _confirmarContrasenaController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (_isEditing && _contrasenaController.text.isNotEmpty) {
                                        if (value != _contrasenaController.text) {
                                          return 'Las contraseñas no coinciden';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Agregar imagen y logout
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Agregar imagen
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Agregar',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0E3520),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: _handleImageUpload,
                                            child: Container(
                                              width: 120,
                                              height: 97,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color(0xFF0E3520),
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.circular(5),
                                                color: Colors.white,
                                              ),
                                              child: const Icon(
                                                Icons.add_photo_alternate,
                                                size: 43,
                                                color: Color(0xFF0E3520),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Logout button
                                      GestureDetector(
                                        onTap: _handleLogout,
                                        child: Container(
                                          width: 37.5,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFAE0000),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: const Icon(
                                            Icons.logout,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 27),
                                  
                                  // Advertencia
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
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFAE0000),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  if (_errorMessage != null)
                                    const SizedBox(height: 27),
                                  
                                  // Botones
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Botón Cancelar
                                      GestureDetector(
                                        onTap: _handleCancel,
                                        child: Container(
                                          width: 136.64,
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
                                      
                                      const SizedBox(width: 13),
                                      
                                      // Botón Editar
                                      GestureDetector(
                                        onTap: _handleEdit,
                                        child: Container(
                                          width: 136.64,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0E3520),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Editar',
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
                                  
                                  const SizedBox(height: 80),
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
          
          // Bottom navbar
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: MenuNavegation(
                currentIndex: 2,
                onTap: (index) {
                  // La navegación se maneja dentro de MenuNavegation
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
