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
      height: 141,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la especie
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 12, bottom: 15),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  child: Container(
                    width: 76,
                    height: 114,
                    decoration: BoxDecoration(
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
                            width: 76,
                            height: 114,
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
                    left: 10,
                    top: 19,
                    right: 40,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nombre común
                      Text(
                        species.speciesName,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E3520),
                          letterSpacing: 0.95,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Unidad de muestreo
                      _buildInfoRow(
                        'Unidad de muestreo:',
                        species.unitName,
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // Tipo funcional
                      _buildInfoRow(
                        'Tipo funcional:',
                        species.functionalTypeName,
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // Número de individuos
                      _buildInfoRow(
                        'Número de individuos:',
                        '${species.individualCount}',
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // Altura o estrato
                      _buildInfoRow(
                        'Altura o estrato:',
                        '${species.heightStratumMin}-${species.heightStratumMax}m',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Menú de opciones (3 puntos)
          Positioned(
            right: 15,
            top: 102,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: const Color(0xFF0E3520),
                size: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              offset: const Offset(-10, 0),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3520),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'Editar',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1F5F9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAE0000),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1F5F9),
                      ),
                      textAlign: TextAlign.center,
                    ),
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
      width: 76,
      height: 114,
      color: const Color(0xFF0E3520).withOpacity(0.1),
      child: const Icon(
        Icons.eco,
        color: Color(0xFF0E3520),
        size: 40,
      ),
    );
  }
}
