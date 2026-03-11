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
  State<ProjectListScreen> createState() => ProjectListScreenState();
}

class ProjectListScreenState extends State<ProjectListScreen> {
  final ProjectService _projectService = ProjectService();
  final ScrollController _scrollController = ScrollController();

  final List<Plot> _allProjects = [];
  int? _nextCursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _scrollController.addListener(_onScroll);
  }

  void refresh() => _loadProjects();

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
          content: const Text('Error al cargar más proyectos'),
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
      builder: (dialogContext) => Dialog(
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
                    const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 36),
                    const SizedBox(height: 10),
                    const Text('Eliminar proyecto', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(project.name, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    const Text('Esta acción eliminará el proyecto permanentemente y no se puede deshacer.', style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF0E3520), height: 1.4), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
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
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              await _deleteProject(project.id);
                            },
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
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/FondoHome.png',
            height: 612,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 54,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/logos/sylvara_logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 22, fontFamily: 'Montserrat', color: Color(0xFF0E3520)),
                          children: [
                            TextSpan(text: 'Mis', style: TextStyle(fontWeight: FontWeight.normal)),
                            TextSpan(text: ' Proyectos', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase().trim()),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0E3520), fontFamily: 'Montserrat'),
                            decoration: InputDecoration(
                              hintText: 'Buscar proyecto...',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400], fontFamily: 'Montserrat'),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(Icons.search, color: const Color(0xFF0E3520).withOpacity(0.7), size: 22),
                        ),
                      ],
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
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Expanded(child: _buildContent()),
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
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectFormScreen()));
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
  bool _obscure = true;

  bool get _isActive => widget.project.status == 'active';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                  Icon(
                    _isActive ? Icons.toggle_off_outlined : Icons.toggle_on_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isActive ? 'Desactivar proyecto' : 'Activar proyecto',
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.project.name,
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Confirma tu contraseña para continuar', style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF0E3520))),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Montserrat'),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0E3520), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF9E9E9E), size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0E3520), width: 2)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD32F2F))),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2)),
                      ),
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, color: Color(0xFF0E3520)),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0E3520), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0E3520))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              Navigator.of(context).pop(_passwordController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E3520),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text('Confirmar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}