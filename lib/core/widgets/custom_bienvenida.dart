import 'package:flutter/material.dart';

class CustomBienvenida extends StatelessWidget {
  final String nombre;
  final Color? textColor;

  const CustomBienvenida({
    super.key,
    required this.nombre,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 215,
      height: 27,
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Bienvenido ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.normal,
                  color: textColor ?? const Color(0xFF0E3520),
                  fontFamily: 'Montserrat',
                ),
              ),
              TextSpan(
                text: nombre,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? const Color(0xFF0E3520),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
