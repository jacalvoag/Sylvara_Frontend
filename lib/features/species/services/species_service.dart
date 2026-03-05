import '../models/models.dart';

/// Servicio para gestionar especies en zonas de estudio
/// 
/// Proporciona operaciones CRUD para especies y acceso al catálogo
class SpeciesService {
  // Singleton pattern
  static final SpeciesService _instance = SpeciesService._internal();
  factory SpeciesService() => _instance;
  SpeciesService._internal();
  
  // Getter para acceso al singleton
  static SpeciesService get instance => _instance;

  // Mock data para desarrollo
  final Map<String, List<Map<String, dynamic>>> _mockSpeciesByZone = {};
  final Map<int, List<Map<String, dynamic>>> _mockCatalogByProject = {};

  /// Obtener especies de una zona específica (GET /projects/:projectId/zones/:zoneId/species)
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// - zoneId: ID de la zona de estudio
  /// - cursor: Cursor para paginación (opcional)
  /// - limit: Límite de resultados por página (default: 20)
  /// 
  /// Respuestas:
  /// - 200: Retorna PaginatedSpeciesResponse con especies
  /// - 404: Zona no encontrada
  /// - 500: Error del servidor
  Future<PaginatedSpeciesResponse> getSpeciesInZone(
    int projectId,
    int zoneId, {
    String? cursor,
    int limit = 20,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.get(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones/$zoneId/species?cursor=$cursor&limit=$limit'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );

    final key = '$projectId-$zoneId';

    // Inicializar mock si no existe
    if (!_mockSpeciesByZone.containsKey(key)) {
      _mockSpeciesByZone[key] = [
        {
          'speciesZoneId': 1,
          'speciesId': 101,
          'speciesName': 'Quercus robur',
          'speciesImageUrl': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400',
          'functionalTypeId': 1,
          'functionalTypeName': 'Árbol',
          'individualCount': 15,
          'heightStratumMin': 10.0,
          'heightStratumMax': 25.0,
          'unitId': 1,
          'unitName': 'Metros',
          'cycleNumber': 1,
        },
        {
          'speciesZoneId': 2,
          'speciesId': 102,
          'speciesName': 'Pinus sylvestris',
          'speciesImageUrl': 'https://images.unsplash.com/photo-1606041008023-472dfb5e530f?w=400',
          'functionalTypeId': 1,
          'functionalTypeName': 'Árbol',
          'individualCount': 22,
          'heightStratumMin': 8.0,
          'heightStratumMax': 30.0,
          'unitId': 1,
          'unitName': 'Metros',
          'cycleNumber': 1,
        },
        {
          'speciesZoneId': 3,
          'speciesId': 103,
          'speciesName': 'Rubus fruticosus',
          'speciesImageUrl': null,
          'functionalTypeId': 2,
          'functionalTypeName': 'Arbusto',
          'individualCount': 45,
          'heightStratumMin': 0.5,
          'heightStratumMax': 2.5,
          'unitId': 1,
          'unitName': 'Metros',
          'cycleNumber': 1,
        },
      ];
    }

    final allSpecies = _mockSpeciesByZone[key]!;
    
    // Simular paginación
    int startIndex = 0;
    if (cursor != null && cursor.isNotEmpty) {
      startIndex = int.tryParse(cursor) ?? 0;
    }

    final endIndex = (startIndex + limit).clamp(0, allSpecies.length);
    final paginatedData = allSpecies.sublist(startIndex, endIndex);
    
    final hasMore = endIndex < allSpecies.length;
    final nextCursor = hasMore ? endIndex.toString() : null;

    return PaginatedSpeciesResponse(
      data: paginatedData.map((json) => SpeciesRecord.fromJson(json)).toList(),
      meta: SpeciesMeta(
        nextCursor: nextCursor,
        limit: limit,
      ),
    );
  }

  /// Obtener catálogo de especies del proyecto (GET /projects/:projectId/zones/:zoneId/catalog)
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// - zoneId: ID de la zona (para contexto)
  /// - cursor: Cursor para paginación (opcional)
  /// - limit: Límite de resultados por página (default: 20)
  /// 
  /// Respuestas:
  /// - 200: Retorna PaginatedCatalogResponse con especies del catálogo
  /// - 404: Proyecto no encontrado
  /// - 500: Error del servidor
  Future<PaginatedCatalogResponse> getSpeciesCatalog(
    int projectId,
    int zoneId, {
    String? cursor,
    int limit = 20,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.get(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones/$zoneId/catalog?cursor=$cursor&limit=$limit'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );

    // Inicializar mock si no existe
    if (!_mockCatalogByProject.containsKey(projectId)) {
      _mockCatalogByProject[projectId] = [
        {
          'speciesId': 101,
          'speciesName': 'Quercus robur',
          'speciesImageUrl': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400',
          'functionalTypeName': 'Árbol',
          'totalIndividuals': 45,
        },
        {
          'speciesId': 102,
          'speciesName': 'Pinus sylvestris',
          'speciesImageUrl': 'https://images.unsplash.com/photo-1606041008023-472dfb5e530f?w=400',
          'functionalTypeName': 'Árbol',
          'totalIndividuals': 68,
        },
        {
          'speciesId': 103,
          'speciesName': 'Rubus fruticosus',
          'speciesImageUrl': null,
          'functionalTypeName': 'Arbusto',
          'totalIndividuals': 120,
        },
        {
          'speciesId': 104,
          'speciesName': 'Fagus sylvatica',
          'speciesImageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
          'functionalTypeName': 'Árbol',
          'totalIndividuals': 32,
        },
        {
          'speciesId': 105,
          'speciesName': 'Hedera helix',
          'speciesImageUrl': null,
          'functionalTypeName': 'Trepadora',
          'totalIndividuals': 89,
        },
      ];
    }

    final allCatalog = _mockCatalogByProject[projectId]!;
    
    // Simular paginación
    int startIndex = 0;
    if (cursor != null && cursor.isNotEmpty) {
      startIndex = int.tryParse(cursor) ?? 0;
    }

    final endIndex = (startIndex + limit).clamp(0, allCatalog.length);
    final paginatedData = allCatalog.sublist(startIndex, endIndex);
    
    final hasMore = endIndex < allCatalog.length;
    final nextCursor = hasMore ? endIndex.toString() : null;

    return PaginatedCatalogResponse(
      data: paginatedData.map((json) => CatalogSpecies.fromJson(json)).toList(),
      meta: SpeciesMeta(
        nextCursor: nextCursor,
        limit: limit,
      ),
    );
  }

  /// Registrar especie en zona (POST /projects/:projectId/zones/:zoneId/species)
  /// 
  /// Este método maneja 3 escenarios diferentes:
  /// - 201: Especie creada exitosamente → SpeciesCreated
  /// - 200: Especie existe en catálogo, contador actualizado → SpeciesExistsInCatalog
  /// - 409: Especie ya existe en la zona → SpeciesExistsInZone
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// - zoneId: ID de la zona de estudio
  /// - request: Datos de la especie a registrar
  /// 
  /// Retorna: RegisterSpeciesResult (sealed class con 3 posibles tipos)
  Future<RegisterSpeciesResult> registerSpecies(
    int projectId,
    int zoneId,
    SpeciesRequest request,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.post(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones/$zoneId/species'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(request.toJson()),
    // );

    // Validaciones
    if (request.individualCount <= 0) {
      throw const SpeciesException(
        message: 'Individual count must be greater than 0',
        statusCode: 422,
      );
    }

    if (request.heightStratumMin < 0 || request.heightStratumMax <= request.heightStratumMin) {
      throw const SpeciesException(
        message: 'Invalid height stratum range',
        statusCode: 422,
      );
    }

    final key = '$projectId-$zoneId';
    final allSpecies = _mockSpeciesByZone[key] ?? [];

    // Verificar si la especie ya existe en esta zona (409)
    final existingInZone = allSpecies.where((s) => s['speciesId'] == request.speciesId).toList();
    if (existingInZone.isNotEmpty) {
      final existing = existingInZone.first;
      return SpeciesExistsInZone(
        SpeciesExistsInZoneResponse(
          message: 'Species already exists in this zone',
          speciesZoneId: existing['speciesZoneId'] as int,
          speciesId: existing['speciesId'] as int,
          speciesName: existing['speciesName'] as String,
          individualCount: existing['individualCount'] as int,
        ),
      );
    }

    // Verificar si la especie existe en el catálogo del proyecto (200)
    final catalog = _mockCatalogByProject[projectId] ?? [];
    final existingInCatalog = catalog.where((s) => s['speciesId'] == request.speciesId).toList();
    
    if (existingInCatalog.isNotEmpty) {
      final catalogSpecies = existingInCatalog.first;
      
      // Actualizar contador en catálogo
      catalogSpecies['totalIndividuals'] = 
          (catalogSpecies['totalIndividuals'] as int) + request.individualCount;
      
      return SpeciesExistsInCatalog(
        SpeciesExistsInCatalogResponse(
          message: 'Species exists in catalog, count updated',
          speciesId: catalogSpecies['speciesId'] as int,
          speciesName: catalogSpecies['speciesName'] as String,
          totalIndividuals: catalogSpecies['totalIndividuals'] as int,
        ),
      );
    }

    // Crear nueva especie (201)
    final newId = allSpecies.isEmpty ? 1 : (allSpecies.last['speciesZoneId'] as int) + 1;
    
    final newSpecies = {
      'speciesZoneId': newId,
      'speciesId': request.speciesId,
      'speciesName': 'Species ${request.speciesId}', // En producción vendría del catálogo
      'speciesImageUrl': null,
      'functionalTypeId': request.functionalTypeId,
      'functionalTypeName': _getFunctionalTypeName(request.functionalTypeId),
      'individualCount': request.individualCount,
      'heightStratumMin': request.heightStratumMin,
      'heightStratumMax': request.heightStratumMax,
      'unitId': request.unitId,
      'unitName': request.unitId == 1 ? 'Metros' : 'Centímetros',
      'cycleNumber': 1,
    };

    allSpecies.add(newSpecies);
    _mockSpeciesByZone[key] = allSpecies;

    return SpeciesCreated(SpeciesRecord.fromJson(newSpecies));
  }

  /// Actualizar registro de especie (PATCH /projects/:projectId/zones/:zoneId/species/:speciesZoneId)
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// - zoneId: ID de la zona de estudio
  /// - speciesZoneId: ID del registro de especie en zona
  /// - request: Datos actualizados
  /// 
  /// Respuestas:
  /// - 200: Retorna SpeciesRecord actualizado
  /// - 404: Registro no encontrado
  /// - 422: Datos inválidos
  /// - 500: Error del servidor
  Future<SpeciesRecord> updateSpeciesRecord(
    int projectId,
    int zoneId,
    int speciesZoneId,
    SpeciesRequest request,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.patch(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones/$zoneId/species/$speciesZoneId'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(request.toJson()),
    // );

    // Validaciones
    if (request.individualCount <= 0) {
      throw const SpeciesException(
        message: 'Individual count must be greater than 0',
        statusCode: 422,
      );
    }

    final key = '$projectId-$zoneId';
    final allSpecies = _mockSpeciesByZone[key] ?? [];

    final index = allSpecies.indexWhere((s) => s['speciesZoneId'] == speciesZoneId);
    if (index == -1) {
      throw const SpeciesException(
        message: 'Species record not found',
        statusCode: 404,
      );
    }

    // Actualizar registro
    allSpecies[index] = {
      ...allSpecies[index],
      'functionalTypeId': request.functionalTypeId,
      'functionalTypeName': _getFunctionalTypeName(request.functionalTypeId),
      'individualCount': request.individualCount,
      'heightStratumMin': request.heightStratumMin,
      'heightStratumMax': request.heightStratumMax,
      'unitId': request.unitId,
      'unitName': request.unitId == 1 ? 'Metros' : 'Centímetros',
    };

    return SpeciesRecord.fromJson(allSpecies[index]);
  }

  /// Eliminar registro de especie (DELETE /projects/:projectId/zones/:zoneId/species/:speciesZoneId)
  /// 
  /// Parámetros:
  /// - projectId: ID del proyecto
  /// - zoneId: ID de la zona de estudio
  /// - speciesZoneId: ID del registro de especie en zona
  /// 
  /// Respuestas:
  /// - 204: Eliminado exitosamente
  /// - 404: Registro no encontrado
  /// - 500: Error del servidor
  Future<void> deleteSpeciesRecord(
    int projectId,
    int zoneId,
    int speciesZoneId,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: En producción, reemplazar con llamada HTTP real
    // final response = await http.delete(
    //   Uri.parse('https://api.sylvara.com/projects/$projectId/zones/$zoneId/species/$speciesZoneId'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //   },
    // );

    final key = '$projectId-$zoneId';
    final allSpecies = _mockSpeciesByZone[key] ?? [];

    final index = allSpecies.indexWhere((s) => s['speciesZoneId'] == speciesZoneId);
    if (index == -1) {
      throw const SpeciesException(
        message: 'Species record not found',
        statusCode: 404,
      );
    }

    allSpecies.removeAt(index);
    _mockSpeciesByZone[key] = allSpecies;
  }

  // Helper para obtener nombre del tipo funcional
  String _getFunctionalTypeName(int typeId) {
    switch (typeId) {
      case 1:
        return 'Árbol';
      case 2:
        return 'Arbusto';
      case 3:
        return 'Hierba';
      case 4:
        return 'Trepadora';
      default:
        return 'Otro';
    }
  }
}
