import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/menu_navegation.dart';
import 'package:sylvara_frontend/features/projects/screens/screens.dart';

class MainScaffold extends StatefulWidget {
  final int currentIndex;
  final Widget child;

  const MainScaffold({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  void _onNavTap(int index) {
    if (index == widget.currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const PantallaInicio();
        break;
      case 1:
        screen = const ProjectListScreen();
        break;
      case 2:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final isGoingRight = index > widget.currentIndex;

          final slideIn = Tween<Offset>(
            begin: Offset(isGoingRight ? 0.08 : -0.08, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position: slideIn,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: MenuNavegation(
            currentIndex: widget.currentIndex,
            onTap: _onNavTap,
          ),
        ),
      ],
    );
  }
}