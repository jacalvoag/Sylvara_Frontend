import 'package:flutter/material.dart';
import '../models/models.dart';
import 'biodiversity_chart.dart';

/// Tarjeta acordeón para mostrar información de una Zona de Estudio
/// 
/// Características:
/// - Header con nombre, descripción y área de la zona
/// - Cuerpo expandible con BiodiversityChart y valores de índices
/// - PopupMenu con opciones: Editar, Flora y Fauna, Eliminar
/// - Modo comparación: checkbox para seleccionar zonas
class StudyZoneCard extends StatefulWidget {
  final StudyZone zone;
  final int index;
  final bool isComparing;
  final bool isSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onViewFloraFauna;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onSelectionChanged;
  final bool initiallyExpanded;

  const StudyZoneCard({
    super.key,
    required this.zone,
    required this.index,
    this.isComparing = false,
    this.isSelected = false,
    this.onEdit,
    this.onViewFloraFauna,
    this.onDelete,
    this.onSelectionChanged,
    this.initiallyExpanded = false,
  });

  @override
  State<StudyZoneCard> createState() => _StudyZoneCardState();
}

class _StudyZoneCardState extends State<StudyZoneCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (_isExpanded) _buildExpandedContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF0E3520),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(_isExpanded ? 22 : 25),
          ),
          padding: EdgeInsets.fromLTRB(
            28,
            _isExpanded ? 12.72 : 15.77,
            20,
            _isExpanded ? 12 : 15.77,
          ),
          child: Row(
            children: [
              // Icono de montaña
              Container(
                width: 45.66,
                height: 45.66,
                decoration: const BoxDecoration(
                  color: Color(0xFF0E3520),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.terrain,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 22),
              // Información de la zona
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de la zona
                    Text(
                      widget.zone.nameStudyZone,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0E3520),
                        letterSpacing: 0.95,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Descripción (ciclo)
                    Text(
                      'Zona de estudio ${widget.index}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF0E3520),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Badge de área
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8E6C9).withValues(alpha: 0.25),
                        border: Border.all(color: const Color(0xFF0E3520)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${widget.zone.subArea.toStringAsFixed(0)}${widget.zone.unitName}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0E3520),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Acción: Menú o Checkbox o Flecha
              if (widget.isComparing)
                Checkbox(
                  value: widget.isSelected,
                  onChanged: widget.onSelectionChanged != null
                      ? (value) => widget.onSelectionChanged!(value ?? false)
                      : null,
                  activeColor: const Color(0xFF0E3520),
                  checkColor: Colors.white,
                )
              else if (_isExpanded)
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Color(0xFF0E3520),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = false;
                    });
                  },
                )
              else
                _buildPopupMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
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
          value: 'flora_fauna',
          child: Row(
            children: [
              Icon(Icons.eco_outlined, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 12),
              Text('Flora y Fauna', style: TextStyle(color: Color(0xFF0E3520), fontFamily: 'Montserrat', fontSize: 14)),
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
            widget.onEdit?.call();
            break;
          case 'flora_fauna':
            widget.onViewFloraFauna?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
    );
  }

  Widget _buildExpandedContent() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna de índices (valores numéricos)
                Expanded(
                  flex: 2,
                  child: _buildIndicesColumn(),
                ),
                const SizedBox(width: 16),
                // Gráfico de biodiversidad
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 180,
                    padding: const EdgeInsets.all(8),
                    child: BiodiversityChart(
                      indices: widget.zone.indices,
                      height: 180,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        _buildIndexRow('S\'', widget.zone.indices.shannon),
        const SizedBox(height: 11),
        _buildIndexRow('D', widget.zone.indices.simpson),
        const SizedBox(height: 11),
        _buildIndexRow('d', widget.zone.indices.margalef),
        const SizedBox(height: 11),
        _buildIndexRow('J\'', widget.zone.indices.pielou),
      ],
    );
  }

  Widget _buildIndexRow(String label, double value) {
    return Text(
      '$label = ${value.toStringAsFixed(2)}',
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0E3520),
        height: 1.02,
      ),
    );
  }
}
