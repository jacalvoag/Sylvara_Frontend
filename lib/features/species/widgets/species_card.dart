import 'package:flutter/material.dart';
import '../models/models.dart';

class SpeciesCard extends StatelessWidget {
  final SpeciesRecord species;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SpeciesCard({
    super.key,
    required this.species,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Border decorativo interno
          Positioned.fill(
            left: 5,
            right: 5,
            top: 3,
            bottom: 6,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF0E3520),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          
          // Contenido principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen de la especie
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 12, bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 85,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: species.speciesImageUrl != null && 
                           species.speciesImageUrl!.isNotEmpty
                        ? Image.network(
                            species.speciesImageUrl!,
                            width: 85,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
              ),
              
              // Información de la especie
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 14,
                    top: 14,
                    right: 40,
                    bottom: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nombre común
                      Text(
                        species.speciesName,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E3520),
                          letterSpacing: 0.5,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tipo funcional
                      _buildInfoRow(
                        'Tipo funcional:',
                        species.functionalTypeName,
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // Número de individuos
                      _buildInfoRow(
                        'Individuos:',
                        '${species.individualCount}',
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // Altura o estrato
                      _buildInfoRow(
                        'Altura:',
                        '${species.heightStratumMin.toStringAsFixed(0)}-${species.heightStratumMax.toStringAsFixed(0)} m',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Menú de opciones (3 puntos) - siempre en la esquina superior derecha
          Positioned(
            right: 10,
            top: 10,
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
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Color(0xFF0E3520),
          height: 1.0,
        ),
        children: [
          TextSpan(
            text: '$label   ',
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 85,
      height: 110,
      color: const Color(0xFF0E3520).withOpacity(0.1),
      child: const Icon(
        Icons.eco,
        color: Color(0xFF0E3520),
        size: 40,
      ),
    );
  }
}
