import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/menu_navegation.dart';
import 'package:sylvara_frontend/features/projects/screens/pantalla_inicio.dart';
import 'package:sylvara_frontend/features/projects/screens/project_list_screen.dart';
import 'package:sylvara_frontend/features/projects/screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  // Las tres pantallas se instancian UNA sola vez y nunca se destruyen
  static const List<Widget> _screens = [
    PantallaInicio(),
    ProjectListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // IndexedStack mantiene las 3 pantallas vivas simultáneamente
          // Solo muestra la activa, pero no destruye las otras
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Navbar fija, siempre en la misma posición, nunca se reconstruye
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: MenuNavegation(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == _currentIndex) return;
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}