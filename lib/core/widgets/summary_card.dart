import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final Color? backgroundColor;
  final Color? textColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            blurRadius: 10,
            spreadRadius: 0,
            color: Colors.black.withOpacity(0.15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor ?? const Color(0xFF0E3520),
              letterSpacing: 1.1,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: textColor ?? const Color(0xFF0E3520),
              letterSpacing: 2.5,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
