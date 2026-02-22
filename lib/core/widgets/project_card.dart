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
              // Logo/Imagen del proyecto (20x20)
              SizedBox(
                width: 20,
                height: 20,
                child: Image.network(
                  project.imagen,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E3520).withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 12,
                        color: Color(0xFF0E3520),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Centro: Nombre y Descripción
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
                      ),
                    ),
                    const SizedBox(height: 2),
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9).withOpacity(0.25),
                  border: Border.all(
                    color: const Color(0xFF0E3520),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  project.isActive ? 'Activo' : 'Inactivo',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0E3520),
                    letterSpacing: 0.5,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
