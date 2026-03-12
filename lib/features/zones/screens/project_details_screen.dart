import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'study_zone_list_screen.dart';
import '../../export/services/export_service.dart';

/// Pantalla de detalles de un proyecto que muestra las zonas de estudio.
///
/// Características:
/// - Header glassmorphism con métricas globales
/// - Lista de zonas con accordion cards
/// - CRUD: crear, editar, eliminar zonas
/// - Pull-to-refresh
/// - Exportar PDF (botón glass top-right)
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

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  void _loadZones() {
    setState(() {
      _zonesFuture = StudyZoneService.instance.getProjectZones(widget.projectId);
    });
  }

  Future<void> _navigateToZones() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyZoneListScreen(
          projectId: widget.projectId,
          projectName: widget.projectName,
        ),
      ),
    );
    if (mounted) _loadZones();
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
                top: 0, left: 0, right: 0, height: imageHeight,
                child: Image.asset(
                  'assets/images/backgrounds/FondoProject.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // ─── BACK BUTTON (top-left) ────────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: _glassButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // ─── EXPORT BUTTON (top-right) ─────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: _GlassExportButton(
                  projectId: widget.projectId,
                  projectName: widget.projectName ?? 'proyecto',
                ),
              ),

              // ─── PROJECT NAME OVERLAY (glassmorphism) ─────────────────
              Positioned(
                top: imageHeight - 110, left: 0, right: 0,
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
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1,
                        ),
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

              // ─── WHITE CARD ───────────────────────────────────────────
              Positioned(
                top: imageHeight - 36, left: 0, right: 0, bottom: 0,
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
    );
  }

  /// Glassmorphism circular button (reutilizable para nav)
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
    final metrics = response.globalMetrics;
    final zoneCount = response.zones.length;

    return RefreshIndicator(
      onRefresh: () async => _loadZones(),
      color: const Color(0xFF0E3520),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          // ─── GLOBAL METRICS ──────────────────────────────────────
          _buildMetricsSection(metrics),
          const SizedBox(height: 24),

          // ─── VER ZONAS BUTTON ─────────────────────────────────────
          GestureDetector(
            onTap: _navigateToZones,
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
                  const Icon(Icons.terrain, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ver zonas de estudio ($zoneCount)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF5C7C6A)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GlassExportButton
//
// Botón glass idéntico al de navegación (back), colocado en top-right.
// Maneja internamente el estado de carga y errores.
// ─────────────────────────────────────────────────────────────────────────────

class _GlassExportButton extends StatefulWidget {
  final int projectId;
  final String projectName;

  const _GlassExportButton({
    required this.projectId,
    required this.projectName,
  });

  @override
  State<_GlassExportButton> createState() => _GlassExportButtonState();
}

class _GlassExportButtonState extends State<_GlassExportButton> {
  bool _loading = false;

  Future<void> _handleExport() async {
    setState(() => _loading = true);
    try {
      final service = ExportService();
      final report = await service.getReportData(widget.projectId);
      final pdfBytes = await service.buildPdf(report);

      if (!mounted) return;

      final fileName =
          'sylvara_${widget.projectName.toLowerCase().replaceAll(' ', '_')}_ciclo${report.cycleNumber}.pdf';
      await service.shareOrSavePdf(context, pdfBytes, fileName);
    } on ExportException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al generar el reporte.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(11),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Exportar PDF',
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _handleExport,
                ),
        ),
      ),
    );
  }
}