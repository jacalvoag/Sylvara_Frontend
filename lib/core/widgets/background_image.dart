import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  final String imagePath;
  final double height;

  const BackgroundImage({
    super.key,
    required this.imagePath,
    this.height = 612,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Image.asset(
        imagePath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
