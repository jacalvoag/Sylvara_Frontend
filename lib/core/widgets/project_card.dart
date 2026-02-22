import 'package:flutter/material.dart';
import 'package:sylvara_frontend/features/projects/models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 0),
                blurRadius: 15,
                spreadRadius: 0,
                color: Colors.black.withOpacity(0.10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Logo/Imagen del proyecto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                project.imagen,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3520).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF0E3520),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Centro: Nombre y Descripción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    project.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0E3520),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF0E3520).withOpacity(0.80),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Badge de estado
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: project.isActive
                    ? const Color(0xFFC8E6C9).withOpacity(0.25)
                    : const Color(0xFFE2E8F0).withOpacity(0.60),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                project.isActive ? 'Activo' : 'Inactivo',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0E3520),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
