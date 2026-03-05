import 'dart:convert';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';
import 'package:sylvara_frontend/features/projects/models/models.dart';
class ProjectService {
  // Singleton pattern para mantener una única instancia
  final _apiClient = ApiClient();
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
  final response = await _apiClient.get(ApiConfig.dashboard);
  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return DashboardResponse.fromJson(data);
  } else {
    throw ProjectException(
      message: data['message'] ?? 'Error al cargar el dashboard',
      statusCode: response.statusCode,
    );
  }
}

  /// Obtener todos los proyectos con paginación (GET /projects)
  /// 
  /// Parámetros:
  /// - status: Filtrar por estado ('active', 'inactive', etc.)
  /// - cursor: Cursor de paginación para cargar más proyectos
  /// - limit: Cantidad de proyectos a cargar (por defecto 20)
  /// 
  /// Simula el comportamiento del backend:
  /// - 200: Retorna respuesta paginada con data y meta
  /// - 401: No autenticado
  /// - 404: No se encontraron proyectos (NOT_FOUND)
  /// - 500: Error del servidor
  Future<PaginatedProjectsResponse> getProjects({
    String? status,
    int? cursor,
    int limit = 20,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final queryParams = <String, dynamic>{
    //   if (status != null) 'status': status,
    //   if (cursor != null) 'cursor': cursor,
    //   'limit': limit,
    // };
    // final uri = Uri.parse('https://api.sylvara.com/projects').replace(queryParameters: queryParams);
    // final response = await http.get(
    //   uri,
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );

    // Si no hay proyectos mock, inicializar con datos de ejemplo
    if (_mockProjects.isEmpty) {
      _mockProjects.addAll([
        {
          'samplingPlotId': 1,
          'samplingPlotName': 'Predio Cuba Libre',
          'totalArea': 1500.5,
          'unitId': 2,
          'unitName': 'Hectáreas',
          'samplingPlotStatus': 'active',
          'currentCycleNumber': 1,
          'startDate': '2026-02-15T10:30:00Z',
          'endDate': null,
          'imageUrl': 'https://via.placeholder.com/48',
        },
        {
          'samplingPlotId': 2,
          'samplingPlotName': 'Reserva Natural del Noreste',
          'totalArea': 2800.0,
          'unitId': 2,
          'unitName': 'Hectáreas',
          'samplingPlotStatus': 'active',
          'currentCycleNumber': 2,
          'startDate': '2026-02-10T08:15:00Z',
          'endDate': null,
          'imageUrl': 'https://via.placeholder.com/48',
        },
        {
          'samplingPlotId': 3,
          'samplingPlotName': 'Parque Nacional Sierra Verde',
          'totalArea': 5000.0,
          'unitId': 2,
          'unitName': 'Hectáreas',
          'samplingPlotStatus': 'inactive',
          'currentCycleNumber': 1,
          'startDate': '2026-01-20T12:00:00Z',
          'endDate': '2026-02-20T09:30:00Z',
          'imageUrl': 'https://via.placeholder.com/48',
        },
      ]);
    }

    // Filtrar por estado si se especifica
    List<Map<String, dynamic>> filteredProjects = _mockProjects;
    if (status != null) {
      filteredProjects = _mockProjects
          .where((p) => p['samplingPlotStatus'] == status)
          .toList();
    }

    // Si no hay proyectos después del filtro
    if (filteredProjects.isEmpty) {
      throw ProjectException(
        message: 'No se encontraron proyectos',
        statusCode: 404, // NOT_FOUND
      );
    }

    // Aplicar paginación
    final startIndex = cursor ?? 0;
    final endIndex = (startIndex + limit).clamp(0, filteredProjects.length);
    final paginatedData = filteredProjects.sublist(startIndex, endIndex);

    // Determinar si hay más datos
    final hasMore = endIndex < filteredProjects.length;
    final nextCursor = hasMore ? endIndex : null;

    print('📋 Se obtuvieron ${paginatedData.length} proyectos (cursor: $cursor, limit: $limit)');
    print('📄 Siguiente cursor: $nextCursor');

    final response = {
      'data': paginatedData,
      'meta': {
        'nextCursor': nextCursor,
        'limit': limit,
      },
    };

    return PaginatedProjectsResponse.fromJson(response);
  }

  /// Crear un nuevo proyecto (POST /projects)
  /// 
  /// Simula el comportamiento del backend:
  /// - 201: Proyecto creado exitosamente
  /// - 400: Datos inválidos
  /// - 401: No autenticado
  /// - 422: Área excedida (AREA_EXCEEDED)
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

    // Validar área excedida (422 - Unprocessable Entity)
    if (request.area != null && request.area! > 10000) {
      throw ProjectException(
        message: 'El área excede el límite máximo permitido',
        statusCode: 422, // AREA_EXCEEDED
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
    final projectId = _mockProjects.length + 1;
    
    final newProject = {
      'samplingPlotId': projectId,
      'samplingPlotName': request.nombre,
      'totalArea': request.area,
      'unitId': request.unitId,
      'unitName': request.unitId == 1 ? 'Metros' : 'Hectáreas',
      'samplingPlotStatus': 'active',
      'currentCycleNumber': 1,
      'startDate': now.toIso8601String(),
      'endDate': null,
      'imageUrl': request.imagen ?? 'https://via.placeholder.com/48',
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
  /// - 404: Proyecto no encontrado (NOT_FOUND)
  /// - 422: Área excedida (AREA_EXCEEDED)
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

    // Validar área excedida (422 - Unprocessable Entity)
    if (request.area != null && request.area! > 10000) {
      throw ProjectException(
        message: 'El área excede el límite máximo permitido',
        statusCode: 422, // AREA_EXCEEDED
      );
    }

    // Buscar el proyecto
    final projectIndex = _mockProjects.indexWhere((p) => p['samplingPlotId'].toString() == id);
    
    if (projectIndex == -1) {
      throw ProjectException(
        message: 'Proyecto no encontrado',
        statusCode: 404, // NOT_FOUND
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
      'samplingPlotId': int.parse(id),
      'samplingPlotName': request.nombre,
      'totalArea': request.area ?? existingProject['totalArea'],
      'unitId': request.unitId ?? existingProject['unitId'],
      'unitName': request.unitId != null
          ? (request.unitId == 1 ? 'Metros' : 'Hectáreas')
          : existingProject['unitName'],
      'samplingPlotStatus': existingProject['samplingPlotStatus'],
      'currentCycleNumber': existingProject['currentCycleNumber'],
      'startDate': existingProject['startDate'],
      'endDate': existingProject['endDate'],
      'imageUrl': request.imagen ?? existingProject['imageUrl'],
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
  /// - 404: Proyecto no encontrado (NOT_FOUND)
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
    final projectIndex = _mockProjects.indexWhere((p) => p['samplingPlotId'].toString() == id);
    
    if (projectIndex == -1) {
      throw ProjectException(
        message: 'Proyecto no encontrado',
        statusCode: 404, // NOT_FOUND
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
      'samplingPlotStatus': request.samplingPlotStatus,
      'endDate': request.samplingPlotStatus == 'inactive' 
          ? DateTime.now().toIso8601String() 
          : null,
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
  /// - 404: Proyecto no encontrado (NOT_FOUND)
  /// - 500: Error del servidor
  Future<void> deleteProject(String id) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Buscar el proyecto
    final projectIndex = _mockProjects.indexWhere((p) => p['samplingPlotId'].toString() == id);
    
    if (projectIndex == -1) {
      throw ProjectException(
        message: 'Proyecto no encontrado',
        statusCode: 404, // NOT_FOUND
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
    final projectName = _mockProjects[projectIndex]['samplingPlotName'];
    _mockProjects.removeAt(projectIndex);
    print('🗑️ Proyecto eliminado: $projectName');
  }
}
