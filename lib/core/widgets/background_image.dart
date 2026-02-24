import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar una imagen de fondo con efecto de desvanecimiento
/// 
/// Este widget se puede usar en diferentes pantallas para mantener consistencia
/// en el diseño visual.
class BackgroundImage extends StatelessWidget {
  /// Ruta del asset de la imagen de fondo
  final String imagePath;
  
  /// Altura del contenedor de la imagen (por defecto 610px)
  final double height;
  
  /// Colores de fallback si la imagen no se puede cargar
  final List<Color> fallbackGradientColors;
  
  /// Paradas del gradiente de desvanecimiento
  final List<double> fadeStops;
  
  /// Colores del gradiente de desvanecimiento
  final List<Color> fadeColors;

  const BackgroundImage({
    super.key,
    required this.imagePath,
    this.height = 610,
    this.fallbackGradientColors = const [
      Color(0xFFE8F5E9),
      Color(0xFFF1F5F9),
    ],
    this.fadeStops = const [0.0, 0.5, 0.85, 1.0],
    List<Color>? fadeColors,
  }) : fadeColors = fadeColors ?? const [];

  @override
  Widget build(BuildContext context) {
    // Colores por defecto para el fade si no se proporcionan
    final List<Color> effectiveFadeColors = fadeColors.isEmpty
        ? [
            Colors.transparent,
            Colors.transparent,
            Colors.white.withOpacity(0.7),
            Colors.white,
          ]
        : fadeColors;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback con gradiente si no hay imagen
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: fallbackGradientColors,
                    ),
                  ),
                );
              },
            ),
          ),
          // Gradiente de desvanecimiento en la parte inferior
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: effectiveFadeColors,
                  stops: fadeStops,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
