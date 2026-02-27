import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/projects/models/models.dart';
import 'package:sylvara_frontend/features/projects/services/project_service.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMenuIndex = 0;
  final _projectService = ProjectService();
  late Future<DashboardResponse> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Cargar datos del dashboard al inicializar
    _dashboardFuture = _projectService.getDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DashboardResponse>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // Estado de error
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          // Estado exitoso con datos
          if (snapshot.hasData) {
            final dashboard = snapshot.data!;
            return _buildSuccessState(dashboard);
          }

          // Estado por defecto (no debería llegar aquí)
          return _buildLoadingState();
        },
      ),
      // MenuNavegation en el bottomNavigationBar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: MenuNavegation(
          currentIndex: _selectedMenuIndex,
          onTap: (index) {
            setState(() {
              _selectedMenuIndex = index;
            });
            print('Opción de menú seleccionada: $index');
          },
        ),
      ),
    );
  }

  /// Estado de carga mientras se obtienen los datos
  Widget _buildLoadingState() {
    return Stack(
      children: [
        const BackgroundImage(
          imagePath: 'assets/images/backgrounds/FondoHome.png',
          height: 610,
        ),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF0E3520),
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Cargando datos...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0E3520),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Estado de error si falla la carga
  Widget _buildErrorState(String error) {
    return Stack(
      children: [
        const BackgroundImage(
          imagePath: 'assets/images/backgrounds/FondoHome.png',
          height: 610,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFFAE0000),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Error al cargar los datos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E3520),
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAE0000),
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _dashboardFuture = _projectService.getDashboardData();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E3520),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Reintentar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Estado exitoso con datos del dashboard
  Widget _buildSuccessState(DashboardResponse dashboard) {
    return Stack(
      children: [
        // Imagen de fondo con efecto de desvanecimiento
        const BackgroundImage(
          imagePath: 'assets/images/backgrounds/FondoHome.png',
          height: 610,
        ),
        // Contenido principal
        SafeArea(
          child: Column(
            children: [
              // Encabezado: CustomBienvenida con nombre del usuario
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: 230,
                ),
                child: CustomBienvenida(nombre: dashboard.user.userName),
              ),

              // TabBar personalizado con glassmorphism
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E3520),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF0E3520),
                        unselectedLabelColor: Colors.white,
                        indicator: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        padding: const EdgeInsets.all(3),
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontFamily: 'Montserrat',
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontFamily: 'Montserrat',
                        ),
                        tabs: const [
                          Tab(text: 'RESUMEN'),
                          Tab(text: 'RECIENTES'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // TabBarView: Contenido intercambiable
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Vista 1: RESUMEN con datos del dashboard
                      _buildResumenView(dashboard.summary),
                      // Vista 2: RECIENTES con proyectos del dashboard
                      _buildRecientesView(dashboard.latestPlots),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Vista 1: RESUMEN - Vinculada con datos del dashboard
  Widget _buildResumenView(DashboardSummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          SummaryCard(
            title: 'Total de proyectos:',
            value: summary.totalHistoricalPlots,
          ),
          const SizedBox(height: 10),
          SummaryCard(
            title: 'Proyectos del mes:',
            value: summary.currentMonthPlots,
          ),
        ],
      ),
    );
  }

  // Vista 2: RECIENTES - Genera lista dinámica desde dashboard
  Widget _buildRecientesView(List<Plot> latestPlots) {
    if (latestPlots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Color(0xFF0E3520),
              ),
              SizedBox(height: 16),
              Text(
                'No hay proyectos recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0E3520),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: latestPlots.length,
      itemBuilder: (context, index) {
        final plot = latestPlots[index];
        // Convertir Plot a Project para compatibilidad con ProjectCard
        final project = plot.toProject();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ProjectCard(
            project: project,
            onTap: () {
              print('Proyecto seleccionado: ${plot.name} (ID: ${plot.id})');
              // TODO: Navegar a detalles del proyecto
            },
          ),
        );
      },
    );
  }
}
