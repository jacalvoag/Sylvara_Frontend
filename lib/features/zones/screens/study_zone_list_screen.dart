import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'study_zone_form_screen.dart';
import '../../species/screens/species_list_screen.dart';

class StudyZoneListScreen extends StatefulWidget {
  final int projectId;
  final String? projectName;

  const StudyZoneListScreen({
    super.key,
    required this.projectId,
    this.projectName,
  });

  @override
  State<StudyZoneListScreen> createState() => _StudyZoneListScreenState();
}

class _StudyZoneListScreenState extends State<StudyZoneListScreen> {
  late Future<ProjectZonesResponse> _zonesFuture;
  bool _isComparing = false;
  final Set<int> _selectedZones = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      if (!_isComparing) _selectedZones.clear();
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
    if (result == true) _loadZones();
  }

  Future<void> _confirmDelete(StudyZone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0E3520),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.terrain, color: Colors.white, size: 36),
                    const SizedBox(height: 10),
                    const Text('Eliminar zona', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(zone.nameStudyZone, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    const Text('Esta acción eliminará la zona de estudio permanentemente y no se puede deshacer.', style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF0E3520), height: 1.4), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0E3520), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0E3520))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text('Eliminar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
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

    if (confirmed != true || !mounted) return;

    try {
      await StudyZoneService.instance.deleteStudyZone(widget.projectId, zone.studyZoneId);
      if (!mounted) return;
      _loadZones();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zona eliminada'), backgroundColor: Color(0xFF4CAF50)),
      );
    } on StudyZoneException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFAE0000)),
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
    if (mounted) _loadZones();
  }

  
  static const List<Color> _zoneColors = [
    Color(0xFF4CAF50),
    Color(0xFF8D6E63), 
  ];

  void _showComparison(List<StudyZone> allZones) {
    if (_selectedZones.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona exactamente 2 zonas para comparar'), backgroundColor: Color(0xFFAE0000)),
      );
      return;
    }
    final zone1 = allZones.firstWhere((z) => z.studyZoneId == _selectedZones.first);
    final zone2 = allZones.firstWhere((z) => z.studyZoneId == _selectedZones.last);

    showDialog(
      context: context,
      builder: (context) {
        final mq = MediaQuery.of(context);
        final topPad = mq.viewPadding.top + 12;
        final botPad = mq.viewPadding.bottom + 12;
        final availH = mq.size.height - topPad - botPad;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(20, topPad, 20, botPad),
          child: Container(
            constraints: BoxConstraints(maxHeight: availH * 0.93),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Encabezado blanco Sylvara ────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    border: Border(bottom: BorderSide(color: Color(0xFFE8F5E9), width: 1)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bar_chart_rounded, color: Color(0xFF0E3520), size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Comparación de Zonas',
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0E3520)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // ── Chips de leyenda ─────────────────────────
                      Row(
                        children: [
                          Expanded(child: _legendChip(zone1.nameStudyZone, 'Ciclo ${zone1.cycleNumber} · ${zone1.subArea} ${zone1.unitName}', _zoneColors[0])),
                          const SizedBox(width: 10),
                          Expanded(child: _legendChip(zone2.nameStudyZone, 'Ciclo ${zone2.cycleNumber} · ${zone2.subArea} ${zone2.unitName}', _zoneColors[1])),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Contenido scrollable ─────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Tabla de índices ────────────────────────
                        const Text(
                          'Índices de biodiversidad',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0E3520), letterSpacing: 0.4),
                        ),
                        const SizedBox(height: 8),
                        _indicesTable(zone1, zone2),

                        const SizedBox(height: 20),

                        // ── Gráfica agrupada ────────────────────────
                        const Text(
                          'Gráfica comparativa',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0E3520), letterSpacing: 0.4),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE8F5E9), width: 1.5),
                          ),
                          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                          child: _ComparisonBarChart(zone1: zone1, zone2: zone2, colors: _zoneColors),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Botón Cerrar ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0E3520),
                        side: const BorderSide(color: Color(0xFF0E3520), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Cerrar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _legendChip(String name, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0E3520)), overflow: TextOverflow.ellipsis, maxLines: 1),
                Text(subtitle, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w400, color: Color(0xFF5C7C6A)), overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicesTable(StudyZone z1, StudyZone z2) {
    final rows = [
      ["S' (Shannon)", z1.indices.shannon.toStringAsFixed(3), z2.indices.shannon.toStringAsFixed(3)],
      ['D (Simpson)', z1.indices.simpson.toStringAsFixed(3), z2.indices.simpson.toStringAsFixed(3)],
      ['d (Margalef)', z1.indices.margalef.toStringAsFixed(3), z2.indices.margalef.toStringAsFixed(3)],
      ["J' (Pielou)", z1.indices.pielou.toStringAsFixed(3), z2.indices.pielou.toStringAsFixed(3)],
    ];

    return Table(
      border: TableBorder.all(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(8)),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
      },
      children: [
        // Encabezado tabla
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
          children: [
            _tableCell('Índice', bold: true),
            _tableCellColor(z1.nameStudyZone, _zoneColors[0], bold: true),
            _tableCellColor(z2.nameStudyZone, _zoneColors[1], bold: true),
          ],
        ),
        for (final row in rows)
          TableRow(children: [
            _tableCell(row[0]),
            _tableCell(row[1], center: true),
            _tableCell(row[2], center: true),
          ]),
      ],
    );
  }

  Widget _tableCell(String text, {bool bold = false, bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: const Color(0xFF0E3520)),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _tableCellColor(String text, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text, style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: const Color(0xFF0E3520)), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: 250,
              child: Image.asset(
                'assets/images/backgrounds/FondoProject.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF0E3520)),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0E3520).withOpacity(0.6), const Color(0xFF0E3520).withOpacity(0.3)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(widget.projectName ?? 'Proyecto', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const Text('Zonas de estudio', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.white70)),
                              ]),
                            ),
                            if (!_isComparing)
                              GestureDetector(
                                onTap: _toggleCompareMode,
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                                  child: const Icon(Icons.compare_arrows, color: Colors.white, size: 20),
                                ),
                              ),
                            if (_isComparing)
                              GestureDetector(
                                onTap: _toggleCompareMode,
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.6), shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 8)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF0E3520)),
                      decoration: InputDecoration(
                        hintText: 'Buscar zona...',
                        hintStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF9E9E9E)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF0E3520), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                                child: const Icon(Icons.close, color: Color(0xFF9E9E9E), size: 18),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    ),
                    child: FutureBuilder<ProjectZonesResponse>(
                      future: _zonesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF0E3520)));
                        }
                        if (snapshot.hasError) {
                          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.error_outline, size: 60, color: Color(0xFFAE0000)),
                            const SizedBox(height: 12),
                            const Text('Error al cargar zonas', style: TextStyle(color: Color(0xFF0E3520), fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _loadZones, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E3520)), child: const Text('Reintentar', style: TextStyle(color: Colors.white))),
                          ]));
                        }

                        final zones = snapshot.data!.zones;
                        final filtered = _searchQuery.isEmpty ? zones : zones.where((z) => z.nameStudyZone.toLowerCase().contains(_searchQuery)).toList();

                        if (filtered.isEmpty) {
                          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.terrain, size: 72, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              zones.isEmpty ? 'No hay zonas de estudio' : 'Sin resultados para "$_searchQuery"',
                              style: const TextStyle(fontSize: 17, color: Color(0xFF0E3520), fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                            ),
                            if (zones.isEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Toca + para agregar la primera zona', style: TextStyle(fontSize: 13, color: Color(0xFF5C7C6A), fontFamily: 'Montserrat')),
                            ],
                          ]));
                        }

                        return RefreshIndicator(
                          onRefresh: () async => _loadZones(),
                          color: const Color(0xFF0E3520),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final zone = filtered[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: StudyZoneCard(
                                  zone: zone,
                                  index: zones.indexOf(zone) + 1,
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
                                            const SnackBar(content: Text('Solo puedes seleccionar 2 zonas'), duration: Duration(seconds: 1)),
                                          );
                                        }
                                      } else {
                                        _selectedZones.remove(zone.studyZoneId);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isComparing)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton.extended(
                heroTag: 'compare_zones',
                onPressed: () => _zonesFuture.then((r) => _showComparison(r.zones)),
                backgroundColor: const Color(0xFF4CAF50),
                icon: const Icon(Icons.bar_chart, color: Color(0xFF0E3520)),
                label: const Text('Comparar', style: TextStyle(color: Color(0xFF0E3520), fontWeight: FontWeight.w600, fontFamily: 'Montserrat')),
              ),
            ),
          FloatingActionButton(
            heroTag: 'add_zone_list',
            onPressed: () => _navigateToForm(),
            backgroundColor: const Color(0xFF0E3520),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ComparisonBarChart extends StatelessWidget {
  final StudyZone zone1;
  final StudyZone zone2;
  final List<Color> colors;

  const _ComparisonBarChart({
    required this.zone1,
    required this.zone2,
    required this.colors,
  });

  double get _maxY {
    final vals = [
      zone1.indices.shannon, zone1.indices.simpson,
      zone1.indices.margalef, zone1.indices.pielou,
      zone2.indices.shannon, zone2.indices.simpson,
      zone2.indices.margalef, zone2.indices.pielou,
    ];
    final max = vals.reduce((a, b) => a > b ? a : b);
    return (max * 1.35).clamp(1.0, double.infinity);
  }

  List<BarChartGroupData> _buildGroups() {
    // Cada índice es un grupo; dentro, cada zona es un rod
    final labels = [
      [zone1.indices.shannon,   zone2.indices.shannon],
      [zone1.indices.simpson,   zone2.indices.simpson],
      [zone1.indices.margalef,  zone2.indices.margalef],
      [zone1.indices.pielou,    zone2.indices.pielou],
    ];
    return List.generate(labels.length, (i) {
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: labels[i][0],
            color: colors[0],
            width: 14,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3), topRight: Radius.circular(3),
            ),
          ),
          BarChartRodData(
            toY: labels[i][1],
            color: colors[1],
            width: 14,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3), topRight: Radius.circular(3),
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY;
    const xLabels = ["S'", 'D', 'd', "J'"];
    final indexNames = ["Shannon (S')", 'Simpson (D)', 'Margalef (d)', "Pielou (J')"];

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          groupsSpace: 20,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0E3520),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final zoneName = rodIndex == 0 ? zone1.nameStudyZone : zone2.nameStudyZone;
                return BarTooltipItem(
                  '${indexNames[group.x]}\n$zoneName\n${rod.toY.toStringAsFixed(3)}',
                  const TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    xLabels[value.toInt()],
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0E3520)),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 5,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 10, color: Color(0xFF5C7C6A)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFF0E3520).withOpacity(0.1), strokeWidth: 1),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: const Color(0xFF0E3520).withOpacity(0.3), width: 1.5),
              bottom: BorderSide(color: const Color(0xFF0E3520).withOpacity(0.3), width: 1.5),
            ),
          ),
          barGroups: _buildGroups(),
        ),
      ),
    );
  }
}
