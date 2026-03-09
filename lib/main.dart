import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/api/token_storage.dart';
import 'package:sylvara_frontend/core/widgets/main_scaffold.dart';
import 'package:sylvara_frontend/features/auth/screens/login_screen.dart';
import 'package:sylvara_frontend/features/projects/screens/pantalla_inicio.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaInicio(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final hasTokens = await TokenStorage().hasTokens();
    setState(() {
      _authenticated = hasTokens;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0E3520)),
        ),
      );
    }
    return _authenticated ? const MainScaffold() : const LoginScreen();
  }
}