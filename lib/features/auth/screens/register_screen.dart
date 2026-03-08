import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/auth/models/models.dart';
import 'package:sylvara_frontend/features/auth/services/auth_service.dart';
import 'package:sylvara_frontend/features/projects/screens/screens.dart';
import 'package:sylvara_frontend/core/widgets/main_scaffold.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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

  Future<void> _selectBirthday() async {
    FocusScope.of(context).unfocus();
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
      final formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      setState(() {
        _birthdayController.text = formattedDate;
      });
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = RegisterRequest(
        name: _nameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        birthday: _birthdayController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final response = await _authService.register(request);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScaffold()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido, ${response.user.name}!'),
          backgroundColor: const Color(0xFF0E3520),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PantallaInicio()),
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Verifica tu red e intenta de nuevo.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/FondoAuth.png',
            height: 612,
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF0E3520),
                            size: 22,
                          ),
                        ),
                      ),
                      const Spacer(),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Regís',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                            TextSpan(
                              text: 'trate',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Formulario scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Completa ',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0E3520),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'tus datos',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 22,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF0E3520),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Nombre
                                CustomTextField(
                                  label: 'Nombre',
                                  placeholder: 'Ej. Gilberto',
                                  controller: _nameController,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Ingresa tu nombre';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Apellidos
                                CustomTextField(
                                  label: 'Apellidos',
                                  placeholder: 'Ej. Malaga Acosta',
                                  controller: _lastnameController,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Ingresa tus apellidos';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Fecha de nacimiento
                                CustomTextField(
                                  label: 'Fecha de nacimiento',
                                  placeholder: 'YYYY-MM-DD',
                                  controller: _birthdayController,
                                  readOnly: true,
                                  onTap: _selectBirthday,
                                  suffixIcon: GestureDetector(
                                    onTap: _selectBirthday,
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.calendar_today_rounded,
                                        size: 20,
                                        color: Color(0xFF0E3520),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Selecciona tu fecha de nacimiento';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Email
                                CustomTextField(
                                  label: 'Correo electrónico',
                                  placeholder: 'correo@ejemplo.com',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Ingresa tu correo';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    );
                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Correo no válido';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Contraseña
                                CustomTextField(
                                  label: 'Contraseña',
                                  placeholder: 'Mínimo 6 caracteres',
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(
                                          () => _obscurePassword = !_obscurePassword);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: const Color(0xFF0E3520)
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa una contraseña';
                                    }
                                    if (value.length < 6) {
                                      return 'Mínimo 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Confirmar contraseña
                                CustomTextField(
                                  label: 'Confirmar contraseña',
                                  placeholder: 'Repite tu contraseña',
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirm,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(
                                          () => _obscureConfirm = !_obscureConfirm);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: const Color(0xFF0E3520)
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirma tu contraseña';
                                    }
                                    return null;
                                  },
                                ),

                                // Error message
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFECACA),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: Color(0xFFDC2626),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFDC2626),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 28),

                                // Botones
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: OutlinedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () => Navigator.pop(context),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: _isLoading
                                                  ? const Color(0xFFCBD5E1)
                                                  : const Color(0xFF0E3520),
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _isLoading
                                                  ? const Color(0xFFCBD5E1)
                                                  : const Color(0xFF0E3520),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed:
                                              _isLoading ? null : _handleRegister,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF0E3520),
                                            disabledBackgroundColor:
                                                const Color(0xFFCBD5E1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  'Registrarse',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
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

                        const SizedBox(height: 40),
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