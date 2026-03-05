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

  @override
  void initState() {
    super.initState();
    _loadSpecies();
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar Especie',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E3520),
          ),
        ),
        content: Text(
          '¿Estás seguro de eliminar "${species.speciesName}"?',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Color(0xFF0E3520),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0E3520),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAE0000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
              content: Text(
                'Especie "${species.speciesName}" eliminada correctamente',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al eliminar: ${e.toString()}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              backgroundColor: const Color(0xFFAE0000),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
    
    if (result == true && mounted) {
      _loadSpecies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1511497584788-876760111969?w=1200',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF0E3520),
                );
              },
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Header con glassmorphism
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFFFD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                            color: Color(0xFFF1F5F9),
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(
                              text: 'Especies ',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: 'Registradas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.zoneName,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: const Color(0xFFF1F5F9).withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Content area con especies
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: FutureBuilder<PaginatedSpeciesResponse>(
                      future: _speciesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0E3520),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFAE0000),
                                    size: 60,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error al cargar las especies',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0E3520),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    snapshot.error.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      color: Color(0xFF0E3520),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadSpecies,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0E3520),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Reintentar',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final response = snapshot.data!;
                        
                        if (response.data.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.terrain,
                                    color: const Color(0xFF0E3520).withOpacity(0.3),
                                    size: 80,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No hay especies registradas',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0E3520),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Presiona el botón + para registrar tu primera especie',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      color: const Color(0xFF0E3520).withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async => _loadSpecies(),
                          color: const Color(0xFF0E3520),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 15,
                              bottom: 90,
                            ),
                            itemCount: response.data.length,
                            itemBuilder: (context, index) {
                              final species = response.data[index];
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
        child: const Icon(
          Icons.add,
          color: Color(0xFFF1F5F9),
          size: 32,
        ),
      ),
    );
  }
}
