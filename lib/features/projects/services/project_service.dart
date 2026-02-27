import 'package:sylvara_frontend/features/projects/models/models.dart';

class ProjectService {
  // Singleton pattern para mantener una única instancia
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

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

  /// Obtener todos los proyectos (para futuro uso)
  Future<List<Plot>> getAllProjects() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Simulación de respuesta
    final mockPlots = [
      {
        'id': '1',
        'name': 'Proyecto Alpha',
        'description': 'Descripción del proyecto Alpha',
        'status': 'active',
        'image_url': 'https://via.placeholder.com/48',
        'created_at': '2026-02-01T10:00:00Z',
        'updated_at': '2026-02-26T10:00:00Z',
      },
      {
        'id': '2',
        'name': 'Proyecto Beta',
        'description': 'Descripción del proyecto Beta',
        'status': 'active',
        'image_url': 'https://via.placeholder.com/48',
        'created_at': '2026-02-05T10:00:00Z',
        'updated_at': '2026-02-25T10:00:00Z',
      },
    ];

    return mockPlots.map((json) => Plot.fromJson(json)).toList();
  }

  /// Crear un nuevo proyecto (para futuro uso)
  Future<Plot> createProject({
    required String name,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newPlot = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'description': description,
      'status': 'active',
      'image_url': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    print('✅ Proyecto creado: $name');
    return Plot.fromJson(newPlot);
  }

  /// Actualizar un proyecto (para futuro uso)
  Future<Plot> updateProject({
    required String id,
    String? name,
    String? description,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final updatedPlot = {
      'id': id,
      'name': name ?? 'Proyecto Actualizado',
      'description': description ?? 'Descripción actualizada',
      'status': status ?? 'active',
      'image_url': null,
      'created_at': '2026-02-01T10:00:00Z',
      'updated_at': DateTime.now().toIso8601String(),
    };

    print('✅ Proyecto actualizado: $id');
    return Plot.fromJson(updatedPlot);
  }

  /// Eliminar un proyecto (para futuro uso)
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('🗑️ Proyecto eliminado: $id');
  }
}
