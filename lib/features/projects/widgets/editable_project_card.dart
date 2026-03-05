import 'package:flutter/material.dart';
import 'package:sylvara_frontend/features/projects/models/dashboard_response.dart';

class EditableProjectCard extends StatelessWidget {
  final Plot project;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const EditableProjectCard({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = project.status == 'active';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        width: double.infinity,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
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
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            border: Border.all(
              color: isActive ? const Color(0xFF0E3520) : const Color(0xFF582F0E),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(23),
          ),
          child: Stack(
            children: [
            // Contenido principal
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de montaña/ubicación
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3520),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.landscape,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Textos y badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Nombre del proyecto
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0E3520),
                            letterSpacing: 0.95,
                            fontFamily: 'Montserrat',
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Descripción
                        Text(
                          project.description,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF0E3520),
                            letterSpacing: 0.6,
                            fontFamily: 'Montserrat',
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Badge de estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFC8E6C9).withOpacity(0.25)
                                : const Color(0xFFE65A5A).withOpacity(0.5),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF0E3520)
                                  : const Color(0xFF700000),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            isActive ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? const Color(0xFF0E3520)
                                  : const Color(0xFF700000),
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menú de opciones en la esquina inferior derecha
            Positioned(
              right: 0,
              bottom: 5,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Color(0xFF0E3520),
                  size: 24,
                ),
                offset: const Offset(-10, 35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF0E3520),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Editar',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0E3520),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'toggle_status',
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.toggle_on : Icons.toggle_off,
                          color: const Color(0xFF0E3520),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isActive ? 'Desactivar' : 'Activar',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0E3520),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFD32F2F),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Eliminar',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD32F2F),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (String value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'toggle_status':
                      onToggleStatus();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
