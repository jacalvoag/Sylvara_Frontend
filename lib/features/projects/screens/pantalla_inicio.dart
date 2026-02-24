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
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0E3520).withOpacity(0.15),
                  Colors.white,
                ],
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Encabezado: CustomBienvenida
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: CustomBienvenida(nombre: 'Malaga'),
                ),

                // TabBar personalizado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 2,
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
                      borderRadius: BorderRadius.circular(25),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF0E3520),
                        unselectedLabelColor: Colors.white,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: const EdgeInsets.all(4),
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

                // TabBarView: Contenido intercambiable
                Expanded(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Column(
        children: [
          SummaryCard(
            title: 'Total de proyectos:',
            value: 25,
          ),
          const SizedBox(height: 20),
          SummaryCard(
            title: 'Proyectos del mes:',
            value: 8,
          ),
        ],
      ),
    );
  }

  // Vista 2: RECIENTES - Solo ProjectCard (limitado a 3)
  Widget _buildRecientesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        children: List.generate(
          proyectos.length,
          (index) => ProjectCard(
            project: proyectos[index],
            onTap: () {
              print('Proyecto seleccionado: ${proyectos[index].nombre}');
            },
          ),
        ),
      ),
    );
  }
}
