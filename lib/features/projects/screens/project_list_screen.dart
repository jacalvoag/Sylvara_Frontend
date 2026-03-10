import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
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
  final ScrollController _scrollController = ScrollController();

  final List<Plot> _allProjects = [];
  int? _nextCursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreProjects();
    }
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _allProjects.clear();
      _nextCursor = null;
      _isLoadingMore = false;
    });

    try {
      final response = await _projectService.getProjects(limit: 20);
      if (!mounted) return;
      setState(() {
        _allProjects.addAll(response.data);
        _nextCursor = response.meta.nextCursor;
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

  Future<void> _loadMoreProjects() async {
    if (_isLoadingMore || _nextCursor == null || !mounted) return;
    setState(() => _isLoadingMore = true);

    try {
      final response = await _projectService.getProjects(
        cursor: _nextCursor,
        limit: 20,
      );
      if (!mounted) return;
      setState(() {
        _allProjects.addAll(response.data);
        _nextCursor = response.meta.nextCursor;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar más proyectos'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(Plot project) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57C00), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: const Text(
                '¿Eliminar proyecto?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E3520),
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
            const Text(
              'Estás a punto de eliminar el proyecto:',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666), fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_outlined, color: Color(0xFF0E3520), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0E3520),
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
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFD32F2F), fontFamily: 'Montserrat'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF757575), fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteProject(project.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Eliminar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Proyecto eliminado exitosamente', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
          ]),
          backgroundColor: const Color(0xFF0E3520),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      _loadProjects();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Error al eliminar: $e', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500))),
          ]),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _showPasswordDialog(Plot project) async {
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PasswordDialog(project: project),
    );

    if (password != null && mounted) {
      _toggleProjectStatus(project, password);
    }
  }

  Future<void> _toggleProjectStatus(Plot project, String password) async {
    try {
      final newStatus = project.status == 'active' ? 'inactive' : 'active';
      final request = UpdateStatusRequest(samplingPlotStatus: newStatus, password: password);
      await _projectService.updateProjectStatus(project.id, request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Estado actualizado exitosamente', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
          ]),
          backgroundColor: const Color(0xFF0E3520),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      _loadProjects();
    } on ProjectException catch (e) {
      if (!mounted) return;
      final message = e.statusCode == 401 ? 'Contraseña incorrecta' : 'Error al actualizar el estado';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500))),
          ]),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }




  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0E3520)),
            SizedBox(height: 16),
            Text('Cargando proyectos...', style: TextStyle(fontSize: 16, color: Color(0xFF666666), fontFamily: 'Montserrat')),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color(0xFFD32F2F)),
              const SizedBox(height: 16),
              const Text('Error al cargar proyectos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
              const SizedBox(height: 8),
              Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontFamily: 'Montserrat')),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProjects,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E3520),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filtrar por búsqueda
    final projects = _searchQuery.isEmpty
        ? _allProjects
        : _allProjects.where((p) => p.samplingPlotName.toLowerCase().contains(_searchQuery)).toList();

    if (projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              const Text('No hay proyectos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E3520), fontFamily: 'Montserrat')),
              const SizedBox(height: 8),
              const Text('Crea tu primer proyecto usando el botón +', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF666666), fontFamily: 'Montserrat')),
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
        if (index == projects.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF0E3520)),
            ),
          );
        }
        final project = projects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EditableProjectCard(
            project: project,
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectFormScreen(project: project)),
              );
              if (result == true) _loadProjects();
            },
            onToggleStatus: () => _showPasswordDialog(project),
            onDelete: () => _showDeleteConfirmationDialog(project),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectDetailsScreen(
                    projectId: project.samplingPlotId,
                    projectName: project.samplingPlotName,
                  ),
                ),
              );
              if (mounted) _loadProjects();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo con altura específica de Figma
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/FondoHome.png',
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
                        decoration: const BoxDecoration(
                          // image: DecorationImage(
                          //   image: AssetImage('assets/images/backgrounds/logo.png'),
                          //   fit: BoxFit.contain,
                          // ),
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
                
                // Contenedor principal y buscador (superposición)
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Fondo difuminado (BackdropFilter)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                            child: Container(
                              height: 120,
                              padding: const EdgeInsets.only(top: 20, left: 55, right: 55),
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
                                    const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.search,
                                        color: Color(0xFF0E3520),
                                        size: 27,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Contenedor principal blanco con borde redondeado superior (superpuesto)
                      Positioned(
                        top: 70, // Superpone el contenedor anterior
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Lista de proyectos
                              Expanded(
                                child: _buildContent(),
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
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProjectFormScreen()),
            );
            if (result == true) _loadProjects();
          },
          backgroundColor: const Color(0xFF0E3520),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  final Plot project;

  const _PasswordDialog({required this.project});

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar estado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0E3520), fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 12),
            Text(
              'Ingresa tu contraseña para cambiar el estatus de ${widget.project.name}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Contraseña',
              placeholder: '••••••••',
              controller: _passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF757575), fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    Navigator.of(context).pop(_passwordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E3520),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Confirmar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}