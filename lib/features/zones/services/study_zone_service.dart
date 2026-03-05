import 'package:sylvara_frontend/features/zones/models/models.dart';

class StudyZoneService {
  // Singleton pattern
  static final StudyZoneService _instance = StudyZoneService._internal();
  factory StudyZoneService() => _instance;
  StudyZoneService._internal();
  
  // Getter para acceso al singleton
  static StudyZoneService get instance => _instance;

  // Simulación de base de datos en memoria
  final Map<int, List<Map<String, dynamic>>> _mockZonesByProject = {};

  /// Obtener zonas de un proyecto (GET /projects/:id/zones)
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// 
  /// Respuestas:
  /// - 200: Retorna ProjectZonesResponse con métricas globales y zonas
  /// - 404: Proyecto no encontrado (NOT_FOUND)
  /// - 500: Error del servidor
  Future<ProjectZonesResponse> getProjectZones(int projectId) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.get(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );

    // Inicializar mock si no existe
    if (!_mockZonesByProject.containsKey(projectId)) {
      // Datos mock para el proyecto
      _mockZonesByProject[projectId] = [
        {
          'studyZoneId': 1,
          'nameStudyZone': 'Zona Norte',
          'subArea': 250.5,
          'unitId': 2,
          'unitName': 'Hectáreas',
          'cycleNumber': 1,
          'indices': {
            'shannon': 2.45,
            'simpson': 0.85,
            'margalef': 3.12,
            'pielou': 0.78,
          },
          'counts': {
            'speciesRichness': 25,
            'totalIndividuals': 150,
          },
        },
        {
          'studyZoneId': 2,
          'nameStudyZone': 'Zona Sur',
          'subArea': 180.0,
          'unitId': 2,
          'unitName': 'Hectáreas',
          'cycleNumber': 1,
          'indices': {
            'shannon': 2.15,
            'simpson': 0.80,
            'margalef': 2.89,
            'pielou': 0.72,
          },
          'counts': {
            'speciesRichness': 20,
            'totalIndividuals': 120,
          },
        },
        {
          'studyZoneId': 3,
          'nameStudyZone': 'Zona Este',
          'subArea': 320.8,
          'unitId': 2,
          'unitName': 'Hectáreas',
          'cycleNumber': 1,
          'indices': {
            'shannon': 2.68,
            'simpson': 0.88,
            'margalef': 3.45,
            'pielou': 0.82,
          },
          'counts': {
            'speciesRichness': 30,
            'totalIndividuals': 180,
          },
        },
      ];
    }

    final zones = _mockZonesByProject[projectId]!;

    // Si no hay zonas, lanzar error 404
    if (zones.isEmpty) {
      throw StudyZoneException(
        message: 'No se encontraron zonas para este proyecto',
        statusCode: 404, // NOT_FOUND
      );
    }

    // Calcular métricas globales (promedio de todas las zonas)
    final totalZones = zones.length;
    double avgShannon = 0, avgSimpson = 0, avgMargalef = 0, avgPielou = 0;
    int totalSpecies = 0, totalIndividuals = 0;

    for (final zone in zones) {
      final indices = zone['indices'] as Map<String, dynamic>;
      final counts = zone['counts'] as Map<String, dynamic>;

      avgShannon += indices['shannon'] as double;
      avgSimpson += indices['simpson'] as double;
      avgMargalef += indices['margalef'] as double;
      avgPielou += indices['pielou'] as double;

      totalSpecies += counts['speciesRichness'] as int;
      totalIndividuals += counts['totalIndividuals'] as int;
    }

    final mockResponse = {
      'samplingPlotId': projectId,
      'cycleNumber': zones[0]['cycleNumber'],
      'globalMetrics': {
        'indices': {
          'shannon': avgShannon / totalZones,
          'simpson': avgSimpson / totalZones,
          'margalef': avgMargalef / totalZones,
          'pielou': avgPielou / totalZones,
        },
        'counts': {
          'speciesRichness': totalSpecies,
          'totalIndividuals': totalIndividuals,
        },
      },
      'zones': zones,
    };

    print('🌍 Zonas obtenidas para proyecto $projectId: ${zones.length}');
    print('📊 Métricas globales - Shannon: ${(avgShannon / totalZones).toStringAsFixed(2)}');

    return ProjectZonesResponse.fromJson(mockResponse);
  }

  /// Crear una zona de estudio (POST /projects/:id/zones)
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// - request: Datos de la zona a crear
  /// 
  /// Respuestas:
  /// - 201: Zona creada exitosamente
  /// - 400: Datos inválidos
  /// - 404: Proyecto no encontrado (NOT_FOUND)
  /// - 422: Área excedida (AREA_EXCEEDED)
  /// - 500: Error del servidor
  Future<StudyZone> createStudyZone(
    int projectId,
    StudyZoneRequest request,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Validaciones (400 - Bad Request)
    if (request.nameStudyZone.isEmpty) {
      throw StudyZoneException(
        message: 'El nombre de la zona es obligatorio',
        statusCode: 400,
      );
    }

    if (request.nameStudyZone.length < 3) {
      throw StudyZoneException(
        message: 'El nombre debe tener al menos 3 caracteres',
        statusCode: 400,
      );
    }

    if (request.subArea <= 0) {
      throw StudyZoneException(
        message: 'El área debe ser mayor a 0',
        statusCode: 400,
      );
    }

    // Validar área excedida (422 - Unprocessable Entity)
    if (request.subArea > 5000) {
      throw StudyZoneException(
        message: 'El área de la zona excede el límite máximo permitido',
        statusCode: 422, // AREA_EXCEEDED
      );
    }

    // Validar que el proyecto existe
    if (!_mockZonesByProject.containsKey(projectId)) {
      _mockZonesByProject[projectId] = [];
    }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.post(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(request.toJson()),
    // );

    final zones = _mockZonesByProject[projectId]!;
    final newZoneId = zones.isNotEmpty 
        ? (zones.map((z) => z['studyZoneId'] as int).reduce((a, b) => a > b ? a : b) + 1)
        : 1;

    final newZone = {
      'studyZoneId': newZoneId,
      'nameStudyZone': request.nameStudyZone,
      'subArea': request.subArea,
      'unitId': request.unitId,
      'unitName': request.unitId == 1 ? 'Metros' : 'Hectáreas',
      'cycleNumber': 1,
      'indices': {
        'shannon': 0.0,
        'simpson': 0.0,
        'margalef': 0.0,
        'pielou': 0.0,
      },
      'counts': {
        'speciesRichness': 0,
        'totalIndividuals': 0,
      },
    };

    zones.add(newZone);
    print('✅ Zona creada: ${request.nameStudyZone} (ID: $newZoneId)');

    return StudyZone.fromJson(newZone);
  }

  /// Actualizar una zona de estudio (PATCH /projects/:id/zones/:zoneId)
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// - zoneId: ID de la zona a actualizar
  /// - request: Datos actualizados de la zona
  /// 
  /// Respuestas:
  /// - 200: Zona actualizada exitosamente
  /// - 400: Datos inválidos
  /// - 404: Proyecto o zona no encontrada (NOT_FOUND)
  /// - 422: Área excedida (AREA_EXCEEDED)
  /// - 500: Error del servidor
  Future<StudyZone> updateStudyZone(
    int projectId,
    int zoneId,
    StudyZoneRequest request,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Validaciones (400 - Bad Request)
    if (request.nameStudyZone.isEmpty) {
      throw StudyZoneException(
        message: 'El nombre de la zona es obligatorio',
        statusCode: 400,
      );
    }

    if (request.subArea <= 0) {
      throw StudyZoneException(
        message: 'El área debe ser mayor a 0',
        statusCode: 400,
      );
    }

    // Validar área excedida (422 - Unprocessable Entity)
    if (request.subArea > 5000) {
      throw StudyZoneException(
        message: 'El área de la zona excede el límite máximo permitido',
        statusCode: 422, // AREA_EXCEEDED
      );
    }

    // Validar que el proyecto existe
    if (!_mockZonesByProject.containsKey(projectId)) {
      throw StudyZoneException(
        message: 'Proyecto no encontrado',
        statusCode: 404, // NOT_FOUND
      );
    }

    final zones = _mockZonesByProject[projectId]!;
    final zoneIndex = zones.indexWhere((z) => z['studyZoneId'] == zoneId);

    if (zoneIndex == -1) {
      throw StudyZoneException(
        message: 'Zona de estudio no encontrada',
        statusCode: 404, // NOT_FOUND
      );
    }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.patch(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones/$zoneId'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(request.toJson()),
    // );

    final existingZone = zones[zoneIndex];
    final updatedZone = {
      ...existingZone,
      'nameStudyZone': request.nameStudyZone,
      'subArea': request.subArea,
      'unitId': request.unitId,
      'unitName': request.unitId == 1 ? 'Metros' : 'Hectáreas',
    };

    zones[zoneIndex] = updatedZone;
    print('✅ Zona actualizada: ${request.nameStudyZone} (ID: $zoneId)');

    return StudyZone.fromJson(updatedZone);
  }

  /// Eliminar una zona de estudio (DELETE /projects/:id/zones/:zoneId)
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// - zoneId: ID de la zona a eliminar
  /// 
  /// Respuestas:
  /// - 204: Zona eliminada exitosamente
  /// - 404: Proyecto o zona no encontrada (NOT_FOUND)
  /// - 500: Error del servidor
  Future<void> deleteStudyZone(int projectId, int zoneId) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 600));

    // Validar que el proyecto existe
    if (!_mockZonesByProject.containsKey(projectId)) {
      throw StudyZoneException(
        message: 'Proyecto no encontrado',
        statusCode: 404, // NOT_FOUND
      );
    }

    final zones = _mockZonesByProject[projectId]!;
    final zoneIndex = zones.indexWhere((z) => z['studyZoneId'] == zoneId);

    if (zoneIndex == -1) {
      throw StudyZoneException(
        message: 'Zona de estudio no encontrada',
        statusCode: 404, // NOT_FOUND
      );
    }

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.delete(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones/$zoneId'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );

    final zoneName = zones[zoneIndex]['nameStudyZone'];
    zones.removeAt(zoneIndex);
    print('🗑️ Zona eliminada: $zoneName (ID: $zoneId)');
  }

  /// Limpiar caché de zonas (útil para testing)
  void clearCache() {
    _mockZonesByProject.clear();
    print('🧹 Caché de zonas limpiado');
  }

  /// Obtener zonas en caché para un proyecto
  List<Map<String, dynamic>>? getCachedZones(int projectId) {
    return _mockZonesByProject[projectId];
  }
}
