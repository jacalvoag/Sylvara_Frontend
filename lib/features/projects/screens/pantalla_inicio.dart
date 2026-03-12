import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/projects/models/models.dart';
import 'package:sylvara_frontend/features/projects/services/project_service.dart';
import 'package:sylvara_frontend/core/api/token_storage.dart';
import 'package:sylvara_frontend/features/benchmarking/screens/screens.dart';
import 'package:sylvara_frontend/features/zones/screens/project_details_screen.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => PantallaInicioState();
}

class PantallaInicioState extends State<PantallaInicio> with TickerProviderStateMixin {
  late TabController _tabController;
  final _projectService = ProjectService();
  DashboardResponse? _dashboard;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Called by MainScaffold when the user switches back to this tab
  void refresh() => _loadData();

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _hasError = false; });
    try {
      final results = await Future.wait([
        _projectService.getDashboardData(),
        TokenStorage().isAdmin(),
      ]);
      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as DashboardResponse;
        _isAdmin = results[1] as bool;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          const BackgroundImage(imagePath: 'assets/images/backgrounds/FondoHome.png', height: 610),
          SafeArea(
            child: Column(
              children: [
                // ── HEADER (always visible) ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 65,
                        height: 70,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/logos/sylvara_logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (!_isLoading && !_hasError && _dashboard != null)
                        CustomBienvenida(nombre: _dashboard!.user.userName),
                      if (_isLoading || _hasError || _dashboard == null)
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
                if (_isAdmin && _dashboard != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BenchmarkingScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFF0E3520), borderRadius: BorderRadius.circular(10)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.speed, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Benchmarking', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // ── TAB BAR (always visible) ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFF0E3520), borderRadius: BorderRadius.circular(22)),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: const Color(0xFF0E3520),
                          unselectedLabelColor: Colors.white,
                          indicator: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(22)),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          padding: const EdgeInsets.all(3),
                          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.8, fontFamily: 'Montserrat'),
                          unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.8, fontFamily: 'Montserrat'),
                          tabs: const [Tab(text: 'RESUMEN'), Tab(text: 'RECIENTES')],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ── WHITE CARD (always visible) ─────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0E3520), strokeWidth: 3))
                        : _hasError
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, size: 64, color: Color(0xFFAE0000)),
                                      const SizedBox(height: 20),
                                      const Text('Error al cargar los datos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E3520), fontFamily: 'Montserrat'), textAlign: TextAlign.center),
                                      const SizedBox(height: 10),
                                      Text(_errorMessage, style: const TextStyle(fontSize: 14, color: Color(0xFFAE0000), fontFamily: 'Montserrat'), textAlign: TextAlign.center),
                                      const SizedBox(height: 30),
                                      ElevatedButton(
                                        onPressed: _loadData,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0E3520),
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Reintentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat')),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildResumenView(_dashboard!.summary),
                                  _buildRecientesView(_dashboard!.latestPlots),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildResumenView(DashboardSummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          SummaryCard(title: 'Total de proyectos:', value: summary.totalHistoricalPlots),
          const SizedBox(height: 10),
          SummaryCard(title: 'Proyectos del mes:', value: summary.currentMonthPlots),
        ],
      ),
    );
  }

  Widget _buildRecientesView(List<Plot> latestPlots) {
    if (latestPlots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF0E3520)),
              SizedBox(height: 16),
              Text('No hay proyectos recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: latestPlots.map((plot) {
          final project = plot.toProject();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProjectCard(
              project: project,
              totalArea: plot.totalArea,
              unitName: plot.unitName,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailsScreen(
                      projectId: plot.samplingPlotId,
                      projectName: plot.samplingPlotName,
                    ),
                  ),
                );
                if (mounted) _loadData();
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}