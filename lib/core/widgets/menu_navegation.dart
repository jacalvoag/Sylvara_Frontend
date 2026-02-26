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
      width: 244,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0E3520),
        border: Border.all(
          color: const Color(0xFF0E3520),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFCFFFD).withOpacity(0.1),
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home icon
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(0),
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          Icons.home,
                          size: 24,
                          color: currentIndex == 0
                              ? (selectedItemColor ?? Colors.white)
                              : (unselectedItemColor ?? Colors.white.withOpacity(0.7)),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Documents icon
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(1),
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          Icons.article,
                          size: 24,
                          color: currentIndex == 1
                              ? (selectedItemColor ?? Colors.white)
                              : (unselectedItemColor ?? Colors.white.withOpacity(0.7)),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Profile/Avatar
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: GestureDetector(
                    onTap: () => onTap(2),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == 2
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
