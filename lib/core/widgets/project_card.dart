import 'package:flutter/material.dart';
import 'package:sylvara_frontend/features/projects/models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final double? totalArea;
  final String? unitName;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.totalArea,
    this.unitName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 390,
          height: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFF0E3520),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 0),
                blurRadius: 10,
                spreadRadius: 0,
                color: Colors.black.withOpacity(0.15),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Imagen del proyecto (48x48)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3520),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    project.imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E3520),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.landscape,
                          size: 28,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Centro: Nombre, Descripción y Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      project.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E3520),
                        letterSpacing: 1.1,
                        fontFamily: 'Montserrat',
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF0E3520),
                        letterSpacing: 0.75,
                        fontFamily: 'Montserrat',
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badges: estado + área
                    Row(
                      children: [
                        _buildBadge(
                          project.isActive ? 'Activo' : 'Inactivo',
                          project.isActive
                              ? const Color(0xFFC8E6C9)
                              : const Color(0xFFFFCDD2),
                          project.isActive
                              ? const Color(0xFF0E3520)
                              : const Color(0xFF700000),
                        ),
                        if (totalArea != null && unitName != null) ...
                          [
                            const SizedBox(width: 6),
                            _buildBadge(
                              '${totalArea!.toStringAsFixed(1)} $unitName',
                              const Color(0xFFE3F2FD),
                              const Color(0xFF0E3520),
                            ),
                          ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.35),
        border: Border.all(color: textColor, width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.5,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}
