import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/auth/models/models.dart';
import 'package:sylvara_frontend/features/auth/services/auth_service.dart';

class TwoFactorScreen extends StatefulWidget {
  final String twoFactorToken;
  final String backLabel;

  const TwoFactorScreen({
    super.key,
    required this.twoFactorToken,
    this.backLabel = 'Volver al inicio de sesión',
  });

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _authService = AuthService();
  final _codeController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() => _errorMessage = 'El código debe tener 6 dígitos.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _authService.verifyTwoFactor(
        twoFactorToken: widget.twoFactorToken,
        code: code,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScaffold()),
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
      body: Stack(
        children: [
          BackgroundImage(
            imagePath: 'assets/images/backgrounds/FondoAuth.png',
            height: MediaQuery.of(context).size.height,
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logos/sylvara_logo.png',
                          width: 50,
                          height: 54,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.eco,
                                size: 50, color: Color(0xFF0E3520));
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
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Verificación ',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0E3520),
                                  ),
                                ),
                                TextSpan(
                                  text: 'en dos pasos',
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
                          const SizedBox(height: 12),
                          Text(
                            'Ingresa el código de 6 dígitos que enviamos a tu correo electrónico.',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              color: const Color(0xFF0E3520).withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0E3520),
                              letterSpacing: 12,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '------',
                              hintStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF0E3520)
                                    .withValues(alpha: 0.2),
                                letterSpacing: 12,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD0D5DD)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD0D5DD)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF0E3520), width: 1.5),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length == 6) _handleVerify();
                            },
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: Color(0xFFDC2626), size: 18),
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
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleVerify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0E3520),
                                disabledBackgroundColor:
                                    const Color(0xFFCBD5E1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Verificar',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap:
                                  _isLoading ? null : () => Navigator.pop(context),
                              child: Text(
                                widget.backLabel,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0E3520)
                                      .withValues(alpha: 0.6),
                                ),
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
          ),
        ],
      ),
    );
  }
}