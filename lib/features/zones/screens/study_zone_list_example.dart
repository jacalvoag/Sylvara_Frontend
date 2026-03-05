import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Ejemplo de pantalla que muestra una lista de zonas de estudio con StudyZoneCard
/// 
/// Demuestra:
/// - Lista de zonas con FutureBuilder
/// - Uso de StudyZoneCard con callbacks
/// - Modo normal y modo comparación
/// - Manejo de acciones (Editar, Flora y Fauna, Eliminar)
class StudyZoneListExampleScreen extends StatefulWidget {
  final int projectId;

  const StudyZoneListExampleScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<StudyZoneListExampleScreen> createState() =>
      _StudyZoneListExampleScreenState();
}

class _StudyZoneListExampleScreenState
    extends State<StudyZoneListExampleScreen> {
  final _service = StudyZoneService();
  late Future<ProjectZonesResponse> _zonesFuture;
  bool _isComparing = false;
  final Set<int> _selectedZones = {};

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  void _loadZones() {
    setState(() {
      _zonesFuture = _service.getProjectZones(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Zonas de Estudio'),
        backgroundColor: const Color(0xFF0E3520),
        foregroundColor: Colors.white,
        actions: [
          // Botón para activar/desactivar modo comparación
          if (!_isComparing)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: () {
                setState(() {
                  _isComparing = true;
                  _selectedZones.clear();
                });
              },
              tooltip: 'Comparar zonas',
            )
          else
            TextButton(
              onPressed: () {
                if (_selectedZones.length >= 2) {
                  _showComparison();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona al menos 2 zonas para comparar'),
                    ),
                  );
                }
              },
              child: const Text(
                'Comparar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (_isComparing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isComparing = false;
                  _selectedZones.clear();
                });
              },
              tooltip: 'Cancelar',
            ),
        ],
      ),
      body: FutureBuilder<ProjectZonesResponse>(
        future: _zonesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0E3520),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFAE0000),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar zonas',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0E3520),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadZones,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E3520),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final response = snapshot.data!;
          
          if (response.zones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.nature_outlined,
                    size: 64,
                    color: Color(0xFF0E3520),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay zonas de estudio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0E3520),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea una zona para comenzar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadZones();
            },
            color: const Color(0xFF0E3520),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: response.zones.length + 1,
              itemBuilder: (context, index) {
                // Header con métricas globales
                if (index == 0) {
                  return _buildGlobalMetricsHeader(response.globalMetrics);
                }

                final zone = response.zones[index - 1];
                return StudyZoneCard(
                  zone: zone,
                  isComparing: _isComparing,
                  isSelected: _selectedZones.contains(zone.studyZoneId),
                  onSelectionChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedZones.add(zone.studyZoneId);
                      } else {
                        _selectedZones.remove(zone.studyZoneId);
                      }
                    });
                  },
                  onEdit: () => _handleEdit(zone),
                  onViewFloraFauna: () => _handleViewFloraFauna(zone),
                  onDelete: () => _handleDelete(zone),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: !_isComparing
          ? FloatingActionButton(
              onPressed: _handleAddZone,
              backgroundColor: const Color(0xFF0E3520),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildGlobalMetricsHeader(GlobalMetrics metrics) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0E3520),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas Globales del Proyecto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E3520),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Riqueza de Especies',
                  '${metrics.counts.speciesRichness}',
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Total Individuos',
                  '${metrics.counts.totalIndividuals}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BiodiversityChart(
            indices: metrics.indices,
            height: 180,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0E3520),
          ),
        ),
      ],
    );
  }

  void _handleEdit(StudyZone zone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar: ${zone.nameStudyZone}'),
        backgroundColor: const Color(0xFF0E3520),
      ),
    );
    // TODO: Navegar a pantalla de edición
    // Navigator.push(context, MaterialPageRoute(...));
  }

  void _handleViewFloraFauna(StudyZone zone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver Flora y Fauna de: ${zone.nameStudyZone}'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
    // TODO: Navegar a lista de especies
    // Navigator.push(context, MaterialPageRoute(...));
  }

  void _handleDelete(StudyZone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar zona'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${zone.nameStudyZone}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFAE0000),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteStudyZone(
          widget.projectId,
          zone.studyZoneId,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${zone.nameStudyZone} eliminada'),
              backgroundColor: Colors.green,
            ),
          );
          _loadZones();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: const Color(0xFFAE0000),
            ),
          );
        }
      }
    }
  }

  void _handleAddZone() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Crear nueva zona de estudio'),
        backgroundColor: Color(0xFF0E3520),
      ),
    );
    // TODO: Navegar a pantalla de creación
    // Navigator.push(context, MaterialPageRoute(...));
  }

  void _showComparison() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comparando ${_selectedZones.length} zonas'),
        backgroundColor: const Color(0xFF0E3520),
      ),
    );
    // TODO: Navegar a pantalla de comparación
    // Navigator.push(context, MaterialPageRoute(...));
  }
}
