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
              color: Colors.black.withValues(alpha: 0.15),
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
                    // Icono
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E3520),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.landscape,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Textos y badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Nombre
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
                          // Descripción — null-safe con fallback vacío
                          Text(
                            project.description ?? '',
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
                          // Badges
                          Row(
                            children: [
                              _buildBadge(
                                isActive ? 'Activo' : 'Inactivo',
                                isActive
                                    ? const Color(0xFFC8E6C9)
                                    : const Color(0xFFFFCDD2),
                                isActive
                                    ? const Color(0xFF0E3520)
                                    : const Color(0xFF700000),
                              ),
                              if (project.totalArea != null &&
                                  project.unitName != null) ...[
                                const SizedBox(width: 6),
                                _buildBadge(
                                  '${project.totalArea!.toStringAsFixed(1)} ${project.unitName}',
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
              // Menú de opciones
              Positioned(
                right: 0,
                bottom: 5,
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF0E3520),
                    size: 24,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  offset: const Offset(0, 40),
                  elevation: 6,
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Color(0xFF0E3520), size: 20),
                          SizedBox(width: 12),
                          Text('Editar', style: TextStyle(color: Color(0xFF0E3520), fontFamily: 'Montserrat', fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(isActive ? Icons.toggle_on : Icons.toggle_off, color: const Color(0xFF0E3520), size: 20),
                          const SizedBox(width: 12),
                          Text(isActive ? 'Desactivar' : 'Activar', style: const TextStyle(color: Color(0xFF0E3520), fontFamily: 'Montserrat', fontSize: 14)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Color(0xFFAE0000), size: 20),
                          SizedBox(width: 12),
                          Text('Eliminar', style: TextStyle(color: Color(0xFFAE0000), fontFamily: 'Montserrat', fontSize: 14)),
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

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.35),
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