import 'package:flutter/material.dart';
import 'package:sylvara_frontend/features/auth/screens/login_screen.dart';
import 'package:sylvara_frontend/features/projects/screens/screens.dart';
import 'package:sylvara_frontend/features/zones/screens/project_details_screen.dart';
import 'package:sylvara_frontend/features/zones/widgets/biodiversity_chart.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaInicio(), // Cambia a la pantalla que quieras probar
    );
  }
}
