import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'study_zone_form_screen.dart';
import '../../species/screens/species_list_screen.dart';

/// Pantalla de detalles de un proyecto que muestra las zonas de estudio.
///
/// Características:
/// - Header glassmorphism con métricas globales
/// - Lista de zonas con accordion cards
/// - Modo comparación (seleccionar hasta 2 zonas)
/// - CRUD: crear, editar, eliminar zonas
/// - Pull-to-refresh
class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  final String? projectName;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    this.projectName,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late Future<ProjectZonesResponse> _zonesFuture;
  bool _isComparing = false;
  bool _showZones = false;
  final Set<int> _selectedZones = {};

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  void _loadZones() {
    setState(() {
      _zonesFuture = StudyZoneService.instance.getProjectZones(widget.projectId);
      _selectedZones.clear();
    });
  }

  void _toggleCompareMode() {
    setState(() {
      _isComparing = !_isComparing;
      if (!_isComparing) {
        _selectedZones.clear();
      }
    });
  }

  Future<void> _navigateToForm({StudyZone? zone}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => StudyZoneFormScreen(
          projectId: widget.projectId,
          zoneId: zone?.studyZoneId,
          existingZone: zone,
        ),
      ),
    );

    if (result == true) {
      _loadZones();
    }
  }

  Future<void> _confirmDelete(StudyZone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Zona'),
        content: Text('¿Estás seguro de eliminar "${zone.nameStudyZone}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFAE0000),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await StudyZoneService.instance.deleteStudyZone(
        widget.projectId,
        zone.studyZoneId,
      );
      if (!mounted) return;
      _loadZones();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zona eliminada exitosamente'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } on StudyZoneException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFAE0000),
        ),
      );
    }
  }

  Future<void> _navigateToSpecies(StudyZone zone) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeciesListScreen(
          projectId: widget.projectId,
          zoneId: zone.studyZoneId,
          zoneName: zone.nameStudyZone,
        ),
      ),
    );
    // Recargar zonas e índices al volver (puede haber cambiado el número de especies)
    if (mounted) {
      _loadZones();
    }
  }

  void _showComparison(List<StudyZone> allZones) {
    if (_selectedZones.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona exactamente 2 zonas para comparar'),
          backgroundColor: Color(0xFFAE0000),
        ),
      );
      return;
    }

    final zone1 = allZones.firstWhere((z) => z.studyZoneId == _selectedZones.first);
    final zone2 = allZones.firstWhere((z) => z.studyZoneId == _selectedZones.last);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comparación de Zonas'),
        contentPadding: const EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zona 1
                _buildComparisonZoneCard(zone1),
                const SizedBox(height: 20),
                // Zona 2
                _buildComparisonZoneCard(zone2),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonZoneCard(StudyZone zone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF0E3520), width: 1.5),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF0E3520),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.terrain,
                  color: Color(0xFFF1F5F9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.nameStudyZone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E3520),
                      ),
                    ),
                    Text(
                      'Ciclo ${zone.cycleNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0E3520),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9).withValues(alpha: 0.25),
                  border: Border.all(color: const Color(0xFF0E3520)),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${zone.subArea}${zone.unitName}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0E3520),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Índices
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "S' = ${zone.indices.shannon.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0E3520),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "D = ${zone.indices.simpson.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0E3520),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "d = ${zone.indices.margalef.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0E3520),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "J' = ${zone.indices.pielou.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0E3520),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Gráfica
          BiodiversityChart(
            indices: zone.indices,
            height: 180,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismHeader(GlobalMetrics metrics) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFCFFFD).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  widget.projectName ?? 'Detalles del Proyecto',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1F5F9),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Monitoreo de especies nativas',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFFF1F5F9),
                    letterSpacing: 0.75,
                  ),
                ),
                const SizedBox(height: 20),
                // Métricas globales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 10,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              metrics.counts.speciesRichness.toString(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                            const Text(
                              'Riqueza de\nEspecies',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 10,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              metrics.counts.totalIndividuals.toString(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                            const Text(
                              'Total de\nIndividuos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.38;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<ProjectZonesResponse>(
        future: _zonesFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              // ─── HERO IMAGE ────────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imageHeight,
                child: Image.asset(
                  'assets/images/backgrounds/FondoProject.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // ─── NAVIGATION BUTTONS (over image) ──────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: _glassButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if (!_isComparing)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: _glassButton(
                    icon: Icons.compare_arrows,
                    onPressed: _toggleCompareMode,
                  ),
                ),

              // ─── PROJECT NAME OVERLAY (glassmorphism, bottom of image) ──
              Positioned(
                top: imageHeight - 110,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.projectName ?? 'Proyecto',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Monitoreo de especies nativas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── WHITE CARD SLIDING OVER IMAGE ───────────────────────
              Positioned(
                top: imageHeight - 36,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _buildBodyContent(snapshot),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isComparing)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton.extended(
                heroTag: 'exit_compare',
                onPressed: _toggleCompareMode,
                backgroundColor: const Color(0xFFF1F5F9),
                icon: const Icon(Icons.close, color: Color(0xFF0E3520)),
                label: const Text(
                  'Salir de comparación',
                  style: TextStyle(
                    color: Color(0xFF0E3520),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          _isComparing
              ? FloatingActionButton.extended(
                  heroTag: 'compare_btn',
                  onPressed: () {
                    _zonesFuture.then((response) => _showComparison(response.zones));
                  },
                  backgroundColor: const Color(0xFF4CAF50),
                  icon: const Icon(Icons.bar_chart, color: Color(0xFF0E3520)),
                  label: const Text(
                    'Comparar',
                    style: TextStyle(
                      color: Color(0xFF0E3520),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : FloatingActionButton(
                  heroTag: 'add_zone',
                  onPressed: () => _navigateToForm(),
                  backgroundColor: const Color(0xFF0E3520),
                  child: const Icon(Icons.add, color: Color(0xFFF1F5F9)),
                ),
        ],
      ),
    );
  }

  /// Glassmorphism circular button for navigation
  Widget _glassButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  /// Builds the scrollable content inside the white card
  Widget _buildBodyContent(AsyncSnapshot<ProjectZonesResponse> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0E3520)),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Color(0xFFAE0000)),
            const SizedBox(height: 16),
            Text(
              'Error: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF0E3520)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadZones,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E3520),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final response = snapshot.data!;
    final zones = response.zones;
    final metrics = response.globalMetrics;

    return RefreshIndicator(
      onRefresh: () async => _loadZones(),
      color: const Color(0xFF0E3520),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
        children: [
          // ─── GLOBAL METRICS ──────────────────────────────────────
          _buildMetricsSection(metrics),
          const SizedBox(height: 24),

          // ─── TOGGLE ZONES BUTTON ─────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _showZones = !_showZones),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0E3520),
                borderRadius: BorderRadius.circular(50),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330E3520),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showZones ? Icons.keyboard_arrow_up : Icons.terrain,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showZones ? 'Ocultar zonas' : 'Ver zonas de estudio',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── ZONES LIST (toggled) ─────────────────────────────────
          if (_showZones) ...
          [
            const SizedBox(height: 20),
            if (zones.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Icon(Icons.terrain, size: 70, color: Color(0xFF0E3520)),
                    SizedBox(height: 16),
                    Text(
                      'No hay zonas de estudio',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF0E3520),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Toca + para agregar la primera zona',
                      style: TextStyle(fontSize: 13, color: Color(0xFF5C7C6A)),
                    ),
                  ],
                ),
              )
            else
              ...zones.map((zone) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: StudyZoneCard(
                      zone: zone,
                      isComparing: _isComparing,
                      isSelected: _selectedZones.contains(zone.studyZoneId),
                      onEdit: () => _navigateToForm(zone: zone),
                      onViewFloraFauna: () => _navigateToSpecies(zone),
                      onDelete: () => _confirmDelete(zone),
                      onSelectionChanged: (selected) {
                        setState(() {
                          if (selected) {
                            if (_selectedZones.length < 2) {
                              _selectedZones.add(zone.studyZoneId);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Solo puedes seleccionar 2 zonas'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          } else {
                            _selectedZones.remove(zone.studyZoneId);
                          }
                        });
                      },
                    ),
                  )),
          ],
        ],
      ),
    );
  }

  /// Sección de métricas globales con grid de 2×2
  Widget _buildMetricsSection(GlobalMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Índices de biodiversidad',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E3520),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _indexCard(metrics.indices.shannon.toStringAsFixed(2), 'Shannon-Wiener'),
            const SizedBox(width: 12),
            _indexCard(metrics.indices.simpson.toStringAsFixed(2), 'Simpson'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _indexCard(metrics.indices.margalef.toStringAsFixed(2), 'Margalef'),
            const SizedBox(width: 12),
            _indexCard(metrics.indices.pielou.toStringAsFixed(2), 'Pielou'),
          ],
        ),
      ],
    );
  }

  Widget _indexCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E3520),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF5C7C6A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
