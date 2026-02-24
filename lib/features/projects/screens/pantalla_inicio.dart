import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/projects/models/models.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMenuIndex = 0;

  // Datos de ejemplo para los proyectos (limitado a 3 para Recientes)
  final List<Project> proyectos = [
    Project(
      id: '1',
      nombre: 'Predio Cuba Libre',
      descripcion: 'Monitoreo de especies nativas',
      isActive: true,
      imagen: 'https://via.placeholder.com/20',
    ),
    Project(
      id: '2',
      nombre: 'Reserva Natural',
      descripcion: 'Estudio de biodiversidad',
      isActive: true,
      imagen: 'https://via.placeholder.com/20',
    ),
    Project(
      id: '3',
      nombre: 'Parque Nacional',
      descripcion: 'Investigación forestal',
      isActive: false,
      imagen: 'https://via.placeholder.com/20',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: Stack(
        children: [
          // Imagen de fondo con efecto de desvanecimiento
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/home_background.jpg',
            height: 610,
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Encabezado: CustomBienvenida
                const Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 14,
                    bottom: 230,
                  ),
                  child: CustomBienvenida(nombre: 'Malaga'),
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
                        // Vista 1: RESUMEN
                        _buildResumenView(),
                        // Vista 2: RECIENTES
                        _buildRecientesView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  // Vista 1: RESUMEN - Solo SummaryCard
  Widget _buildResumenView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          SummaryCard(
            title: 'Total de proyectos:',
            value: 25,
          ),
          const SizedBox(height: 10),
          SummaryCard(
            title: 'Proyectos del mes:',
            value: 5,
          ),
        ],
      ),
    );
  }

  // Vista 2: RECIENTES - Solo ProjectCard (limitado a 3)
  Widget _buildRecientesView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: proyectos.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ProjectCard(
            project: proyectos[index],
            onTap: () {
              print('Proyecto seleccionado: ${proyectos[index].nombre}');
            },
          ),
        );
      },
    );
  }
}
