import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/auth/screens/login_screen.dart';
import 'package:sylvara_frontend/features/profile/models/models.dart';
import 'package:sylvara_frontend/features/profile/services/profile_service.dart';
import 'package:sylvara_frontend/core/api/token_storage.dart';
import 'package:sylvara_frontend/core/services/cloudinary_service.dart';

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
  bool _isLoading = true;
  bool _hasError = false;
  String _errorText = '';
  bool _isSaving = false;
  bool _isEditingMode = false;
  bool _uploadingProfileImage = false;
  String _profilePictureUrl = '';
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _hasError = false; });
    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;
      _fillFormWithProfile(profile);
      setState(() { _profile = profile; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _hasError = true; _errorText = e.toString(); _isLoading = false; });
    }
  }

  void _fillFormWithProfile(UserProfile profile) {
    _nombreController.text = profile.userName;
    _apellidosController.text = profile.userLastname;
    final parts = profile.userBirthday.split('-');
    if (parts.length == 3) {
      _fechaNacimientoController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
    } else {
      _fechaNacimientoController.text = profile.userBirthday;
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

  Future<void> _selectDate() async {
    DateTime initial = DateTime(2000, 1, 1);
    try {
      if (_fechaNacimientoController.text.isNotEmpty) {
        final parts = _fechaNacimientoController.text.split('/');
        if (parts.length == 3) {
          initial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
    } catch (_) {}

    final now = DateTime.now();
    final firstAllowedDate = DateTime(now.year - 100, now.month, now.day);
    final lastAllowedDate = DateTime(now.year - 15, now.month, now.day);

    if (initial.isBefore(firstAllowedDate)) initial = firstAllowedDate;
    else if (initial.isAfter(lastAllowedDate)) initial = lastAllowedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0E3520), onPrimary: Colors.white, onSurface: Color(0xFF0E3520)),
        ),
        child: child!,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _fechaNacimientoController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  String _dateToApiFormat(String display) {
    final parts = display.split('/');
    if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
    return display;
  }

  Future<void> _handleEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; _errorMessage = null; });

    try {
      final request = UpdateProfileRequest(
        userName: _nombreController.text.trim(),
        userLastname: _apellidosController.text.trim(),
        userBirthday: _dateToApiFormat(_fechaNacimientoController.text.trim()),
        userEmail: _correoController.text.trim(),
        profilePictureUrl: _profilePictureUrl,
      );
      final updated = await _profileService.updateProfile(request);
      if (!mounted) return;
      setState(() { _profile = updated; _isSaving = false; _isEditingMode = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Perfil actualizado exitosamente', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
          ]),
          backgroundColor: const Color(0xFF0E3520),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } on ProfileException catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = e.message; _isSaving = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _errorMessage = 'Error al actualizar el perfil'; _isSaving = false; });
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ChangePasswordDialog(),
    );

    if (result != null && mounted) {
      try {
        await _profileService.changePassword(UpdatePasswordRequest(
            currentPassword: result['current']!,
            newPassword: result['new']!));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 12), Text('Contraseña actualizada', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500))]),
            backgroundColor: const Color(0xFF0E3520),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } on ProfileException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(e.message, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)))]),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0E3520),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.person_off_outlined, color: Colors.white, size: 36),
                    SizedBox(height: 10),
                    Text('Eliminar cuenta', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Esta acción es permanente', style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    const Text(
                      'Al eliminar tu cuenta perderás todos tus datos, proyectos y registros. Esta acción no se puede deshacer.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF0E3520), height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0E3520), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0E3520))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              try {
                                await _profileService.deleteAccount();
                                if (!mounted) return;
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (_) => false,
                                );
                              } on ProfileException catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(e.message, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)))]),
                                    backgroundColor: const Color(0xFFD32F2F),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text('Eliminar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Stack(
          children: [
            const BackgroundImage(imagePath: 'assets/images/backgrounds/FondoHome.png', height: 612),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          height: 54,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/logos/sylvara_logo.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(text: 'Mi ', style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.normal, color: Color(0xFF0E3520))),
                              TextSpan(text: 'Perfil', style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E3520))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0E3520)))
                          : _hasError
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 64),
                                      const SizedBox(height: 16),
                                      const Text('Error al cargar el perfil', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0E3520))),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 32),
                                        child: Text(_errorText, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF666666)), textAlign: TextAlign.center),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: _loadProfile,
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E3520), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        child: const Text('Reintentar', style: TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                )
                              : _buildForm(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildForm() {
    final profile = _profile!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Configura tu cuenta', style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E3520))),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _isEditingMode
                  ? () async {
                      if (_uploadingProfileImage) return;
                      setState(() => _uploadingProfileImage = true);
                      try {
                        final url = await CloudinaryService.pickSourceAndUpload(context);
                        if (url != null && mounted) {
                          setState(() => _profilePictureUrl = url);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Foto actualizada. Guarda para confirmar.'), backgroundColor: Color(0xFF4CAF50)),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir foto: $e'), backgroundColor: const Color(0xFFD32F2F)));
                        }
                      } finally {
                        if (mounted) setState(() => _uploadingProfileImage = false);
                      }
                    }
                  : null,
              child: Stack(
                children: [
                  _uploadingProfileImage
                      ? const SizedBox(width: 88, height: 88, child: CircularProgressIndicator(color: Color(0xFF0E3520), strokeWidth: 3))
                      : CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(0xFF0E3520),
                          backgroundImage: _profilePictureUrl.isNotEmpty ? NetworkImage(_profilePictureUrl) : null,
                          child: _profilePictureUrl.isEmpty
                              ? Text(profile.userName.isNotEmpty ? profile.userName[0].toUpperCase() : '?',
                                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white))
                              : null,
                        ),
                  if (_isEditingMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFF0E3520), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('${profile.userName} ${profile.userLastname}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0E3520))),
            Text(profile.userRole, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF666666))),
            const SizedBox(height: 28),
            CustomTextField(label: 'Nombre', placeholder: 'Ej. Gilberto', controller: _nombreController, keyboardType: TextInputType.name, readOnly: !_isEditingMode, validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null),
            const SizedBox(height: 18),
            CustomTextField(label: 'Apellidos', placeholder: 'Ej. Malaga', controller: _apellidosController, keyboardType: TextInputType.name, readOnly: !_isEditingMode, validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tus apellidos' : null),
            const SizedBox(height: 18),
            CustomTextField(
              label: 'Fecha de nacimiento',
              placeholder: 'DD/MM/YYYY',
              controller: _fechaNacimientoController,
              readOnly: true,
              onTap: _isEditingMode ? _selectDate : null,
              suffixIcon: GestureDetector(
                onTap: _isEditingMode ? _selectDate : null,
                child: const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF0E3520))),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Selecciona tu fecha de nacimiento' : null,
            ),
            const SizedBox(height: 18),
            CustomTextField(
              label: 'Correo electrónico',
              placeholder: 'correo@ejemplo.com',
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              readOnly: !_isEditingMode,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Ingresa un correo válido';
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFECACA))),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            if (_isEditingMode) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => setState(() { _isEditingMode = false; _fillFormWithProfile(_profile!); }),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0E3520), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0E3520))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleEdit,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E3520), disabledBackgroundColor: const Color(0xFFCBD5E1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Guardar', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF0E3520)),
                  label: const Text('Cambiar Contraseña', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0E3520))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0E3520), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditingMode = true),
                  icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                  label: const Text('Editar Perfil', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E3520), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await TokenStorage().clear();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                  },
                  icon: const Icon(Icons.logout, size: 18, color: Color(0xFF0E3520)),
                  label: const Text('Cerrar Sesión', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0E3520))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0E3520), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (!_isEditingMode)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _showDeleteAccountDialog,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFD32F2F)),
                  label: const Text('Eliminar Cuenta', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentPwdController.dispose();
    _newPwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cambiar contraseña', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
            const SizedBox(height: 8),
            const Text('Ingresa tu contraseña actual y la nueva', style: TextStyle(fontSize: 13, color: Color(0xFF666666), fontFamily: 'Montserrat')),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Contraseña actual',
              placeholder: '••••••••',
              controller: _currentPwdController,
              obscureText: _obscureCurrent,
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureCurrent = !_obscureCurrent),
                child: Padding(padding: const EdgeInsets.only(right: 12), child: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: const Color(0xFF0E3520).withOpacity(0.5))),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña actual' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Nueva contraseña',
              placeholder: '••••••••',
              controller: _newPwdController,
              obscureText: _obscureNew,
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureNew = !_obscureNew),
                child: Padding(padding: const EdgeInsets.only(right: 12), child: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: const Color(0xFF0E3520).withOpacity(0.5))),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                if (v.length < 8) return 'Mínimo 8 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD0D5DD)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Cancelar', style: TextStyle(color: Color(0xFF757575), fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        Navigator.of(context).pop({'current': _currentPwdController.text, 'new': _newPwdController.text});
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E3520), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                      child: const Text('Actualizar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}