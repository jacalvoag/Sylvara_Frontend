import 'package:flutter/material.dart';
import 'package:sylvara_frontend/features/auth/screens/login_screen.dart';
import 'package:sylvara_frontend/features/auth/screens/register_screen.dart';

import 'package:sylvara_frontend/features/projects/screens/screens.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
