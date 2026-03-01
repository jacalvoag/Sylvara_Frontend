import 'package:sylvara_frontend/features/projects/models/models.dart';
import 'package:sylvara_frontend/features/projects/models/create_project_request.dart';
import 'package:sylvara_frontend/features/projects/models/update_project_request.dart';
import 'package:sylvara_frontend/features/projects/models/update_status_request.dart';
import 'package:sylvara_frontend/features/projects/models/project_exception.dart';

class ProjectService {
  // Singleton pattern para mantener una única instancia
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  // Simulación de base de datos en memoria de proyectos
  final List<Map<String, dynamic>> _mockProjects = [];

  /// Obtener datos del Dashboard (GET /dashboard)
  /// 
  /// Simula el comportamiento del backend:
  /// - 200: Retorna datos del dashboard con user, summary y latest_plots
  /// - 401: No autenticado
  /// - 500: Error del servidor
  Future<DashboardResponse> getDashboardData() async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.get(
    //   Uri.parse('https://api.sylvara.com/dashboard'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );

    // Datos mock simulando la respuesta del backend
    final Map<String, dynamic> mockResponse = {
      'user': {
        'user_name': 'Malaga',
        'profile_picture_url': null, // o 'https://example.com/avatar.jpg'
      },
      'summary': {
        'total_historical_plots': 12,
        'current_month_plots': 3,
      },
      'latest_plots': [
        {
          'id': '1',
          'name': 'Predio Cuba Libre',
          'description': 'Monitoreo de especies nativas en zona protegida',
          'status': 'active',
          'image_url': 'https://via.placeholder.com/48',
          'created_at': '2026-02-15T10:30:00Z',
          'updated_at': '2026-02-26T14:20:00Z',
        },
        {
          'id': '2',
          'name': 'Reserva Natural del Noreste',
          'description': 'Estudio de biodiversidad y conservación',
          'status': 'active',
          'image_url': 'https://via.placeholder.com/48',
          'created_at': '2026-02-10T08:15:00Z',
          'updated_at': '2026-02-25T16:45:00Z',
        },
        {
          'id': '3',
          'name': 'Parque Nacional Sierra Verde',
          'description': 'Investigación forestal y fauna silvestre',
          'status': 'inactive',
          'image_url': 'https://via.placeholder.com/48',
          'created_at': '2026-01-20T12:00:00Z',
          'updated_at': '2026-02-20T09:30:00Z',
        },
      ],
    };

    final userData = mockResponse['user'] as Map<String, dynamic>;
    final summaryData = mockResponse['summary'] as Map<String, dynamic>;
    final plotsData = mockResponse['latest_plots'] as List;
    
    print('📊 Dashboard data obtenido exitosamente');
    print('👤 Usuario: ${userData['user_name']}');
    print('📈 Total proyectos: ${summaryData['total_historical_plots']}');
    print('📅 Proyectos del mes: ${summaryData['current_month_plots']}');
    print('🗂️ Proyectos recientes: ${plotsData.length}');

    return DashboardResponse.fromJson(mockResponse);
  }

  /// Obtener todos los proyectos (GET /projects)
  /// 
  /// Simula el comportamiento del backend:
  /// - 200: Retorna lista de proyectos
  /// - 401: No autenticado
  /// - 500: Error del servidor
  Future<List<Plot>> getProjects() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.get(
    //   Uri.parse('https://api.sylvara.com/projects'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );

    // Si no hay proyectos mock, inicializar con datos de ejemplo
    if (_mockProjects.isEmpty) {
      _mockProjects.addAll([
        {
          'id': '1',
          'name': 'Predio Cuba Libre',
          'description': 'Monitoreo de especies nativas en zona protegida',
          'status': 'active',
          'image_url': 'https://via.placeholder.com/48',
          'created_at': '2026-02-15T10:30:00Z',
          'updated_at': '2026-02-26T14:20:00Z',
        },
        {
          'id': '2',
          'name': 'Reserva Natural del Noreste',
          'description': 'Estudio de biodiversidad y conservación',
          'status': 'active',
          'image_url': 'https://via.placeholder.com/48',
          'created_at': '2026-02-10T08:15:00Z',
          'updated_at': '2026-02-25T16:45:00Z',
        },
        {
          'id': '3',
          'name': 'Parque Nacional Sierra Verde',
          'description': 'Investigación forestal y fauna silvestre',
          'status': 'inactive',
          'image_url': 'https://via.placeholder.com/48',
          'created_at': '2026-01-20T12:00:00Z',
          'updated_at': '2026-02-20T09:30:00Z',
        },
      ]);
    }

    print('📋 Se obtuvieron ${_mockProjects.length} proyectos');
    return _mockProjects.map((json) => Plot.fromJson(json)).toList();
  }

  /// Crear un nuevo proyecto (POST /projects)
  /// 
  /// Simula el comportamiento del backend:
  /// - 201: Proyecto creado exitosamente
  /// - 400: Datos inválidos
  /// - 401: No autenticado
  /// - 500: Error del servidor
  Future<Plot> createProject(CreateProjectRequest request) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Validación de campos (400 - Bad Request)
    if (request.nombre.isEmpty || request.descripcion.isEmpty) {
      throw ProjectException(
        message: 'El nombre y la descripción son obligatorios',
        statusCode: 400,
      );
    }

    // Validar longitud mínima
    if (request.nombre.length < 3) {
      throw ProjectException(
        message: 'El nombre debe tener al menos 3 caracteres',
        statusCode: 400,
      );
    }

    if (request.descripcion.length < 10) {
      throw ProjectException(
        message: 'La descripción debe tener al menos 10 caracteres',
        statusCode: 400,
      );
    }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.post(
    //   Uri.parse('https://api.sylvara.com/projects'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(request.toJson()),
    // );

    // Crear proyecto exitoso (201 - Created)
    final now = DateTime.now();
    final projectId = 'project_${_mockProjects.length + 1}_${now.millisecondsSinceEpoch}';
    
    final newProject = {
      'id': projectId,
      'name': request.nombre,
      'description': request.descripcion,
      'status': 'active',
      'image_url': request.imagen ?? 'https://via.placeholder.com/48',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    _mockProjects.add(newProject);
    print('✅ Proyecto creado: ${request.nombre}');
    
    return Plot.fromJson(newProject);
  }

  /// Actualizar un proyecto (PUT /projects/:id)
  /// 
  /// Simula el comportamiento del backend:
  /// - 200: Proyecto actualizado exitosamente
  /// - 400: Datos inválidos
  /// - 401: No autenticado
  /// - 404: Proyecto no encontrado
  /// - 500: Error del servidor
  Future<Plot> updateProject(String id, UpdateProjectRequest request) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Validación de campos (400 - Bad Request)
    if (request.nombre.isEmpty || request.descripcion.isEmpty) {
      throw ProjectException(
        message: 'El nombre y la descripción son obligatorios',
        statusCode: 400,
      );
    }

    // Buscar el proyecto
    final projectIndex = _mockProjects.indexWhere((p) => p['id'] == id);
    
    if (projectIndex == -1) {
      throw ProjectException(
        message: 'Proyecto no encontrado',
        statusCode: 404,
      );
    }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.put(
    //   Uri.parse('https://api.sylvara.com/projects/$id'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(request.toJson()),
    // );

    // Actualizar proyecto (200 - OK)
    final existingProject = _mockProjects[projectIndex];
    final updatedProject = {
      'id': id,
      'name': request.nombre,
      'description': request.descripcion,
      'status': existingProject['status'],
      'image_url': request.imagen ?? existingProject['image_url'],
      'created_at': existingProject['created_at'],
      'updated_at': DateTime.now().toIso8601String(),
    };

    _mockProjects[projectIndex] = updatedProject;
    print('✅ Proyecto actualizado: ${request.nombre}');
    
    return Plot.fromJson(updatedProject);
  }

  /// Actualizar el estado de un proyecto (PATCH /projects/:id/status)
  /// 
  /// Simula el comportamiento del backend:
  /// - 200: Estado actualizado exitosamente
  /// - 400: Datos inválidos
  /// - 401: Contraseña inválida
  /// - 404: Proyecto no encontrado
  /// - 500: Error del servidor
  Future<Plot> updateProjectStatus(String id, UpdateStatusRequest request) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Validar contraseña (401 - Unauthorized)
    // En este caso simulamos una contraseña hardcodeada "admin123"
    if (request.password != 'admin123') {
      throw ProjectException(
        message: 'Contraseña incorrecta',
        statusCode: 401,
      );
    }

    // Validar estado (400 - Bad Request)
    if (request.samplingPlotStatus != 'active' && request.samplingPlotStatus != 'inactive') {
      throw ProjectException(
        message: 'El estado debe ser "active" o "inactive"',
        statusCode: 400,
      );
    }

    // Buscar el proyecto
    final projectIndex = _mockProjects.indexWhere((p) => p['id'] == id);
    
    if (projectIndex == -1) {
      throw ProjectException(
        message: 'Proyecto no encontrado',
        statusCode: 404,
      );
    }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.patch(
    //   Uri.parse('https://api.sylvara.com/projects/$id/status'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(request.toJson()),
    // );

    // Actualizar estado (200 - OK)
    final existingProject = _mockProjects[projectIndex];
    final updatedProject = {
      ...existingProject,
      'status': request.samplingPlotStatus,
      'updated_at': DateTime.now().toIso8601String(),
    };

    _mockProjects[projectIndex] = updatedProject;
    print('✅ Estado actualizado a: ${request.samplingPlotStatus}');
    
    return Plot.fromJson(updatedProject);
  }

  /// Eliminar un proyecto (DELETE /projects/:id)
  /// 
  /// Simula el comportamiento del backend:
  /// - 204: Proyecto eliminado exitosamente
  /// - 401: No autenticado
  /// - 404: Proyecto no encontrado
  /// - 500: Error del servidor
  Future<void> deleteProject(String id) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Buscar el proyecto
    final projectIndex = _mockProjects.indexWhere((p) => p['id'] == id);
    
    if (projectIndex == -1) {
      throw ProjectException(
        message: 'Proyecto no encontrado',
        statusCode: 404,
      );
    }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.delete(
    //   Uri.parse('https://api.sylvara.com/projects/$id'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );

    // Eliminar proyecto (204 - No Content)
    final projectName = _mockProjects[projectIndex]['name'];
    _mockProjects.removeAt(projectIndex);
    print('🗑️ Proyecto eliminado: $projectName');
  }
}
