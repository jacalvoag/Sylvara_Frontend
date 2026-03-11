import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/species_card.dart';
import 'species_form_screen.dart';

class SpeciesListScreen extends StatefulWidget {
  final int projectId;
  final int zoneId;
  final String zoneName;

  const SpeciesListScreen({
    super.key,
    required this.projectId,
    required this.zoneId,
    required this.zoneName,
  });

  @override
  State<SpeciesListScreen> createState() => _SpeciesListScreenState();
}

class _SpeciesListScreenState extends State<SpeciesListScreen> {
  late Future<PaginatedSpeciesResponse> _speciesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSpecies() {
    setState(() {
      _speciesFuture = SpeciesService.instance.getSpeciesInZone(
        widget.projectId,
        widget.zoneId,
      );
    });
  }

  Future<void> _confirmDelete(SpeciesRecord species) async {
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
                    const Icon(Icons.eco_outlined, color: Colors.white, size: 36),
                    const SizedBox(height: 10),
                    const Text('Eliminar especie', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(species.speciesName, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    const Text('Esta acción eliminará el registro de la especie y no se puede deshacer.', style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF0E3520), height: 1.4), textAlign: TextAlign.center),
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

    if (confirmed == true && mounted) {
      try {
        await SpeciesService.instance.deleteSpeciesRecord(
          widget.projectId,
          widget.zoneId,
          species.speciesZoneId,
        );
        _loadSpecies();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('"${species.speciesName}" eliminada', style: const TextStyle(fontFamily: 'Montserrat'))),
              ]),
              backgroundColor: const Color(0xFF0E3520),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}', style: const TextStyle(fontFamily: 'Montserrat')),
              backgroundColor: const Color(0xFFAE0000),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _navigateToForm([SpeciesRecord? species]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SpeciesFormScreen(
        projectId: widget.projectId,
        zoneId: widget.zoneId,
        zoneName: widget.zoneName,
        species: species,
      ),
    );
    if (result == true && mounted) _loadSpecies();
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
                'assets/images/backgrounds/FondoHome.png',
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
                  colors: [const Color(0xFF0E3520).withOpacity(0.55), const Color(0xFF0E3520).withOpacity(0.25)],
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
                                const Text('Flora y Fauna', style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(widget.zoneName, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ]),
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
                        hintText: 'Buscar especie...',
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
                    child: FutureBuilder<PaginatedSpeciesResponse>(
                      future: _speciesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF0E3520)));
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Icon(Icons.error_outline, color: Color(0xFFAE0000), size: 60),
                                const SizedBox(height: 16),
                                const Text('Error al cargar las especies', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0E3520)), textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadSpecies,
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E3520), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  child: const Text('Reintentar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ]),
                            ),
                          );
                        }
                        final response = snapshot.data!;
                        final allSpecies = response.data;
                        final filtered = _searchQuery.isEmpty ? allSpecies : allSpecies.where((s) => s.speciesName.toLowerCase().contains(_searchQuery)).toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.eco, color: const Color(0xFF0E3520).withOpacity(0.3), size: 80),
                                const SizedBox(height: 16),
                                Text(
                                  allSpecies.isEmpty ? 'No hay especies registradas' : 'Sin resultados para "$_searchQuery"',
                                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E3520)),
                                  textAlign: TextAlign.center,
                                ),
                                if (allSpecies.isEmpty) ...const [
                                  SizedBox(height: 8),
                                  Text('Presiona + para registrar la primera especie', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF5C7C6A)), textAlign: TextAlign.center),
                                ],
                              ]),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async => _loadSpecies(),
                          color: const Color(0xFF0E3520),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final species = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: SpeciesCard(
                                  species: species,
                                  onEdit: () => _navigateToForm(species),
                                  onDelete: () => _confirmDelete(species),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFF0E3520),
        child: const Icon(Icons.add, color: Color(0xFFF1F5F9), size: 32),
      ),
    );
  }
}