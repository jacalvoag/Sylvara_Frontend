import 'package:flutter/material.dart';
import 'dart:ui';

class MenuNavegation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MenuNavegation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MenuNavegation> createState() => _MenuNavegationState();
}

class _MenuNavegationState extends State<MenuNavegation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;
    _controller.forward().then((_) => _controller.reverse());
    setState(() => _previousIndex = widget.currentIndex);
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0E3520).withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E3520).withOpacity(0.92),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _NavItem(
                    index: 0,
                    currentIndex: widget.currentIndex,
                    icon: Icons.home_rounded,
                    label: 'Inicio',
                    onTap: () => _handleTap(0),
                  ),
                  _NavItem(
                    index: 1,
                    currentIndex: widget.currentIndex,
                    icon: Icons.article_rounded,
                    label: 'Proyectos',
                    onTap: () => _handleTap(1),
                  ),
                  _NavItem(
                    index: 2,
                    currentIndex: widget.currentIndex,
                    icon: Icons.person_rounded,
                    label: 'Perfil',
                    onTap: () => _handleTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  icon,
                  key: ValueKey('${index}_$isSelected'),
                  size: isSelected ? 24 : 22,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: isSelected ? 10 : 9,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}