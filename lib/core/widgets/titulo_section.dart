import 'package:flutter/material.dart';

class TituloSection extends StatefulWidget {
  final Function(int) onTabChanged;
  final List<String> tabs;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? activeTextColor;
  final Color? inactiveTextColor;

  const TituloSection({
    super.key,
    this.onTabChanged = _defaultCallback,
    this.tabs = const ['Resumen', 'Recientes'],
    this.backgroundColor,
    this.borderColor,
    this.activeTextColor,
    this.inactiveTextColor,
  });

  static void _defaultCallback(int index) {}

  @override
  State<TituloSection> createState() => _TituloSectionState();
}

class _TituloSectionState extends State<TituloSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: widget.borderColor ?? const Color(0xFFF1F5F9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Fondo gris
          Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          // Pestañas
          Row(
            children: List.generate(
              widget.tabs.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    widget.onTabChanged(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? (widget.backgroundColor ?? const Color(0xFFF1F5F9))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: _selectedIndex == index
                          ? Border.all(
                              color: widget.borderColor ?? const Color(0xFFF1F5F9),
                              width: 1.5,
                            )
                          : null,
                      boxShadow: _selectedIndex == index
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: const Offset(0, 0),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        widget.tabs[index].toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _selectedIndex == index
                              ? (widget.activeTextColor ?? const Color(0xFF0E3520))
                              : (widget.inactiveTextColor ?? Colors.white),
                          letterSpacing: 0.8,
                          fontFamily: 'Montserrat',
                          shadows: _selectedIndex != index
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 0),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
