import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/background_image.dart';
import 'package:sylvara_frontend/core/widgets/menu_navegation.dart';
import 'package:sylvara_frontend/core/widgets/custom_text_field.dart';
import 'package:sylvara_frontend/features/projects/models/dashboard_response.dart';
import 'package:sylvara_frontend/features/projects/models/update_status_request.dart';
import 'package:sylvara_frontend/features/projects/models/project_exception.dart';
import 'package:sylvara_frontend/features/projects/services/project_service.dart';
import 'package:sylvara_frontend/features/projects/widgets/editable_project_card.dart';
import 'package:sylvara_frontend/features/projects/screens/project_form_screen.dart';
import 'package:sylvara_frontend/features/zones/screens/project_details_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ProjectService _projectService = ProjectService();
  late Future<PaginatedProjectsResponse> _projectsFuture;
  
  // Variables para paginación
  final ScrollController _scrollController = ScrollController();
  int? _nextCursor;
  bool _isLoadingMore = false;
  final List<Plot> _allProjects = [];

  // Búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Detectar cuando el usuario llega al 80% del scroll
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreProjects();
      }
    });
  }

  void _loadProjects() {
    setState(() {
      _allProjects.clear();
      _nextCursor = null;
      _projectsFuture = _projectService.getProjects(limit: 20);
    });
  }

  Future<void> _loadMoreProjects() async {
    // Si ya está cargando más o no hay más páginas, no hacer nada
    if (_isLoadingMore || _nextCursor == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _projectService.getProjects(
        cursor: _nextCursor,
        limit: 20,
      );

      setState(() {
        _allProjects.addAll(response.data);
        _nextCursor = response.meta.nextCursor;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar más proyectos: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(Plot project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFF57C00),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¿Eliminar proyecto?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E3520),
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estás a punto de eliminar el proyecto:',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      color: const Color(0xFF0E3520),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        project.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0E3520),
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD32F2F),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF757575),
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteProject(project.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Proyecto eliminado exitosamente',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0E3520),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        _loadProjects(); // Recargar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al eliminar: ${e.toString()}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showPasswordDialog(Plot project) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Cambiar estado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E3520),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              // Mensaje
              Text(
                'Ingresa tu contraseña para cambiar el estatus de ${project.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 20),
              // Campo de contraseña
              CustomTextField(
                label: 'Contraseña',
                placeholder: '••••••••',
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón Cancelar
                  TextButton(
                    onPressed: () {
                      passwordController.dispose();
                      Navigator.of(dialogContext).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF757575),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón Confirmar
                  ElevatedButton(
                    onPressed: () async {
                      final password = passwordController.text;
                      passwordController.dispose();
                      Navigator.of(dialogContext).pop();
                      await _toggleProjectStatus(project, password);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E3520),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Confirmar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleProjectStatus(Plot project, String password) async {
    try {
      final newStatus = project.status == 'active' ? 'inactive' : 'active';
      final request = UpdateStatusRequest(
        samplingPlotStatus: newStatus,
        password: password,
      );

      await _projectService.updateProjectStatus(project.id, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Estado actualizado exitosamente',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0E3520),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        _loadProjects(); // Recargar la lista
      }
    } on ProjectException catch (e) {
      if (mounted) {
        String message = 'Error al actualizar el estado';
        if (e.statusCode == 401) {
          message = 'Contraseña incorrecta';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Imagen de fondo con altura específica de Figma
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/background.png',
            height: 612,
          ),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Header con logo y título "Mis Proyectos"
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo de Sylvara
                      Container(
                        width: 50,
                        height: 54,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/backgrounds/logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Título "Mis Proyectos"
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Montserrat',
                            color: const Color(0xFF0E3520),
                          ),
                          children: [
                            TextSpan(
                              text: 'Mis',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: ' Proyectos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Contenedor con backdrop blur para el buscador (estilo Figma)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                        child: Container(
                          height: 156,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCFFFD).withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Barra de búsqueda
                    Positioned(
                      top: 11,
                      left: 35,
                      right: 35,
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.toLowerCase().trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Buscar proyecto...',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    fontFamily: 'Montserrat',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.search,
                                color: const Color(0xFF0E3520),
                                size: 27,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Contenedor principal con fondo y borde redondeado superior
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        
                        // Lista de proyectos
                        Expanded(
                          child: FutureBuilder<PaginatedProjectsResponse>(
                            future: _projectsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          const Color(0xFF0E3520),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Cargando proyectos...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color(0xFF666666),
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 64,
                                          color: const Color(0xFFD32F2F),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Error al cargar proyectos',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0E3520),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          snapshot.error.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: const Color(0xFF666666),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          onPressed: _loadProjects,
                                          icon: Icon(Icons.refresh),
                                          label: Text('Reintentar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0E3520),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final response = snapshot.data!;
                              final allLoaded = [...response.data, ..._allProjects];

                              // Guardar nextCursor para paginación
                              if (_allProjects.isEmpty && response.data.isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  setState(() {
                                    _allProjects.addAll(response.data);
                                    _nextCursor = response.meta.nextCursor;
                                  });
                                });
                              }

                              // Filtrar por búsqueda
                              final projects = _searchQuery.isEmpty
                                  ? allLoaded
                                  : allLoaded
                                      .where((p) => p.samplingPlotName
                                          .toLowerCase()
                                          .contains(_searchQuery))
                                      .toList();

                              if (projects.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.folder_open,
                                          size: 80,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'No hay proyectos',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0E3520),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Crea tu primer proyecto usando el botón +',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: const Color(0xFF666666),
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(20, 18, 20, 80),
                                itemCount: projects.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // Mostrar indicador de carga al final
                                  if (index == projects.length) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            const Color(0xFF0E3520),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final project = projects[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: EditableProjectCard(
                                      project: project,
                                      onEdit: () async {
                                        // Navegar a pantalla de edición
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProjectFormScreen(
                                              project: project,
                                            ),
                                          ),
                                        );
                                        // Si se editó, recargar lista
                                        if (result == true) {
                                          _loadProjects();
                                        }
                                      },
                                      onToggleStatus: () {
                                        _showPasswordDialog(project);
                                      },
                                      onDelete: () {
                                        _showDeleteConfirmationDialog(project);
                                      },
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProjectDetailsScreen(
                                              projectId: project.samplingPlotId,
                                              projectName: project.samplingPlotName,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 59,
        height: 59,
        margin: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          onPressed: () async {
            // Navegar a pantalla de creación
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProjectFormScreen(),
              ),
            );
            // Si se creó, recargar lista
            if (result == true) {
              _loadProjects();
            }
          },
          backgroundColor: const Color(0xFF0E3520),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29.5),
          ),
          child: const Icon(
            Icons.add,
            size: 46,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: MenuNavegation(
          currentIndex: 1,
          onTap: (index) {
            // La navegación se maneja dentro de MenuNavegation
          },
        ),
      ),
    );
  }
}
