import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/profile/models/models.dart';
import 'package:sylvara_frontend/features/profile/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _correoController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;
  String _profilePictureUrl = '';
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getProfile();
  }

  void _fillFormWithProfile(UserProfile profile) {
    _nombreController.text = profile.userName;
    _apellidosController.text = profile.userLastname;
    // Convertir YYYY-MM-DD a DD/MM/YYYY para mostrar
    final dateParts = profile.userBirthday.split('-');
    if (dateParts.length == 3) {
      _fechaNacimientoController.text = '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
    }
    _correoController.text = profile.userEmail;
    _profilePictureUrl = profile.profilePictureUrl;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _fechaNacimientoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimientoController.text.isNotEmpty
          ? _parseDateFromDisplay(_fechaNacimientoController.text)
          : DateTime(2000, 1, 1),
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

  DateTime _parseDateFromDisplay(String displayDate) {
    try {
      final parts = displayDate.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (e) {
      // Ignore
    }
    return DateTime(2000, 1, 1);
  }

  String _convertDateToApiFormat(String displayDate) {
    // Convertir DD/MM/YYYY a YYYY-MM-DD
    final parts = displayDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return displayDate;
  }

  Future<void> _handleEdit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final request = UpdateProfileRequest(
        userName: _nombreController.text.trim(),
        userLastname: _apellidosController.text.trim(),
        userBirthday: _convertDateToApiFormat(_fechaNacimientoController.text.trim()),
        userEmail: _correoController.text.trim(),
        profilePictureUrl: _profilePictureUrl,
      );

      await _profileService.updateProfile(request);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Perfil actualizado exitosamente';
          _profileFuture = _profileService.getProfile();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  _successMessage!,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0E3520),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } on ProfileException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al actualizar el perfil';
        });
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cambiar contraseña',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E3520),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ingresa tu contraseña actual y la nueva contraseña',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Contraseña actual',
                  placeholder: '••••••••',
                  controller: currentPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Nueva contraseña',
                  placeholder: '••••••••',
                  controller: newPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa la nueva contraseña';
                    }
                    if (value.length < 8) {
                      return 'Mínimo 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        currentPasswordController.dispose();
                        newPasswordController.dispose();
                        Navigator.of(dialogContext).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF757575),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        final request = UpdatePasswordRequest(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                        );

                        currentPasswordController.dispose();
                        newPasswordController.dispose();
                        Navigator.of(dialogContext).pop();

                        try {
                          await _profileService.changePassword(request);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Contraseña actualizada exitosamente',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF0E3520),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        } on ProfileException catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        e.message,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFFD32F2F),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E3520),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Actualizar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD32F2F),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '¿Eliminar cuenta?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E3520),
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Estás seguro de eliminar tu cuenta permanentemente?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFB74D),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFE65100),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta acción no se puede deshacer',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE65100),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF757575),
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                try {
                  await _profileService.deleteAccount();

                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white),
                            const SizedBox(width: 12),
                            const Text(
                              'Cuenta eliminada exitosamente',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF0E3520),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                } on ProfileException catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.message,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFFD32F2F),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleImageUpload() {
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
            child: FutureBuilder<UserProfile>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0E3520),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFD32F2F),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error al cargar el perfil',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0E3520),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'No se encontró el perfil',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                  );
                }

                final profile = snapshot.data!;

                // Prellenar formulario con los datos del perfil
                if (_nombreController.text.isEmpty) {
                  _fillFormWithProfile(profile);
                }

                return Column(
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Foto de perfil
                                      GestureDetector(
                                        onTap: _handleImageUpload,
                                        child: Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 40,
                                              backgroundColor: const Color(0xFF0E3520),
                                              backgroundImage:
                                                  _profilePictureUrl.isNotEmpty
                                                      ? NetworkImage(_profilePictureUrl)
                                                      : null,
                                              child: _profilePictureUrl.isEmpty
                                                  ? Text(
                                                      profile.userName[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        fontFamily: 'Montserrat',
                                                        fontSize: 32,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0E3520),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Nombre del usuario
                                      Text(
                                        '${profile.userName} ${profile.userLastname}',
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0E3520),
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      // Rol del usuario
                                      Text(
                                        profile.userRole,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),

                                      const SizedBox(height: 24),
                                      
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
                                      
                                      const SizedBox(height: 20),
                                      
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
                                      
                                      const SizedBox(height: 20),
                                      
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
                                      
                                      const SizedBox(height: 20),
                                      
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
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Advertencia
                                      if (_errorMessage != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          margin: const EdgeInsets.only(bottom: 16),
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
                                      
                                      // Botones de guardar
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Botón Cancelar
                                          GestureDetector(
                                            onTap: _isLoading ? null : _handleCancel,
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
                                          
                                          // Botón Guardar Cambios
                                          GestureDetector(
                                            onTap: _isLoading ? null : _handleEdit,
                                            child: Container(
                                              width: 136.64,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0E3520),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              alignment: Alignment.center,
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      height: 16,
                                                      width: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Guardar',
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

                                      const SizedBox(height: 24),

                                      // Botón: Cambiar Contraseña
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: _showChangePasswordDialog,
                                          icon: const Icon(
                                            Icons.lock_outline,
                                            size: 16,
                                            color: Color(0xFF0E3520),
                                          ),
                                          label: const Text(
                                            'Cambiar Contraseña',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0E3520),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFF0E3520),
                                              width: 1.5,
                                            ),
                                            padding:
                                                const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Botón: Eliminar Cuenta
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: _showDeleteAccountDialog,
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 16,
                                            color: Color(0xFFD32F2F),
                                          ),
                                          label: const Text(
                                            'Eliminar Cuenta',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFD32F2F),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFD32F2F),
                                              width: 1.5,
                                            ),
                                            padding:
                                                const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
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
                );
              },
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
