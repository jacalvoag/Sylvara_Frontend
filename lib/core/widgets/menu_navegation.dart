import 'package:flutter/material.dart';
import 'dart:ui';

class MenuNavegation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const MenuNavegation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0E3520),
              border: Border.all(
                color: const Color(0xFF0E3520),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    size: 24,
                    color: currentIndex == 0
                        ? (selectedItemColor ?? Colors.white)
                        : (unselectedItemColor ?? Colors.white70),
                  ),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.assignment,
                    size: 24,
                    color: currentIndex == 1
                        ? (selectedItemColor ?? Colors.white)
                        : (unselectedItemColor ?? Colors.white70),
                  ),
                  label: 'Proyectos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    size: 24,
                    color: currentIndex == 2
                        ? (selectedItemColor ?? Colors.white)
                        : (unselectedItemColor ?? Colors.white70),
                  ),
                  label: 'Perfil',
                ),
              ],
              selectedItemColor: selectedItemColor ?? Colors.white,
              unselectedItemColor: unselectedItemColor ?? Colors.white70,
              showSelectedLabels: false,
              showUnselectedLabels: false,
            ),
          ),
        ),
      ),
    );
  }
}
