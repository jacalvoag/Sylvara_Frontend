import 'dart:ui';
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Comparación de Zonas', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E3520))),
        contentPadding: const EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _compCard(zone1),
              const SizedBox(height: 16),
              _compCard(zone2),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar', style: TextStyle(color: Color(0xFF0E3520), fontFamily: 'Montserrat', fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _compCard(StudyZone z) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF0E3520), width: 1.5)),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(backgroundColor: Color(0xFF0E3520), radius: 18, child: Icon(Icons.terrain, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(z.nameStudyZone, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
            Text('Ciclo ${z.cycleNumber} · ${z.subArea} ${z.unitName}', style: const TextStyle(fontSize: 12, color: Color(0xFF5C7C6A))),
          ])),
        ]),
        const Divider(height: 20, color: Color(0xFFE0E0E0)),
        Text("S' (Shannon) = ${z.indices.shannon.toStringAsFixed(3)}", style: const TextStyle(fontSize: 13, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
        const SizedBox(height: 4),
        Text("D (Simpson) = ${z.indices.simpson.toStringAsFixed(3)}", style: const TextStyle(fontSize: 13, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
        const SizedBox(height: 4),
        Text("d (Margalef) = ${z.indices.margalef.toStringAsFixed(3)}", style: const TextStyle(fontSize: 13, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
        const SizedBox(height: 4),
        Text("J' (Pielou) = ${z.indices.pielou.toStringAsFixed(3)}", style: const TextStyle(fontSize: 13, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
        const SizedBox(height: 14),
        BiodiversityChart(indices: z.indices, height: 180),
      ]),
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