import 'dart:convert';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';
import '../models/models.dart';

class SpeciesService {
  static final SpeciesService _instance = SpeciesService._internal();
  factory SpeciesService() => _instance;
  SpeciesService._internal();
  static SpeciesService get instance => _instance;

  final _client = ApiClient();

  Future<PaginatedSpeciesResponse> getSpeciesInZone(
    int projectId,
    int zoneId, {
    String? cursor,
    int limit = 20,
  }) async {
    final url = ApiConfig.speciesInZone(projectId, zoneId, cursor: cursor, limit: limit);
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PaginatedSpeciesResponse.fromJson(json);
    } else if (response.statusCode == 404) {
      throw SpeciesException(message: 'Zona no encontrada.', statusCode: 404);
    } else {
      throw SpeciesException(
        message: 'Error al obtener las especies.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<PaginatedCatalogResponse> getSpeciesCatalog(
    int projectId,
    int zoneId, {
    String? cursor,
    int limit = 20,
  }) async {
    final url = ApiConfig.speciesCatalog(projectId, zoneId, cursor: cursor, limit: limit);
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PaginatedCatalogResponse.fromJson(json);
    } else {
      throw SpeciesException(
        message: 'Error al obtener el catálogo.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<RegisterSpeciesResult> registerSpecies(
    int projectId,
    int zoneId,
    SpeciesRequest request,
  ) async {
    final url = ApiConfig.speciesInZone(projectId, zoneId);
    final response = await _client.post(url, body: request.toJson());
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return SpeciesCreated(SpeciesRecord.fromJson(json));
    } else if (response.statusCode == 200) {
      return SpeciesExistsInCatalog(SpeciesExistsInCatalogResponse.fromJson(json));
    } else if (response.statusCode == 409) {
      return SpeciesExistsInZone(SpeciesExistsInZoneResponse.fromJson(json));
    } else if (response.statusCode == 422) {
      throw SpeciesException(message: json['message'] ?? 'Datos inválidos.', statusCode: 422);
    } else {
      throw SpeciesException(
        message: 'Error al registrar la especie.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<SpeciesRecord> updateSpeciesRecord(
    int projectId,
    int zoneId,
    int speciesZoneId,
    SpeciesUpdateRequest request,
  ) async {
    final url = ApiConfig.speciesZoneById(projectId, zoneId, speciesZoneId);
    final response = await _client.patch(url, body: request.toJson());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SpeciesRecord.fromJson(json);
    } else if (response.statusCode == 404) {
      throw SpeciesException(message: 'Especie no encontrada.', statusCode: 404);
    } else {
      throw SpeciesException(
        message: 'Error al actualizar la especie.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteSpeciesRecord(
    int projectId,
    int zoneId,
    int speciesZoneId,
  ) async {
    final url = ApiConfig.speciesZoneById(projectId, zoneId, speciesZoneId);
    final response = await _client.delete(url);

    if (response.statusCode == 204) return;

    if (response.statusCode == 404) {
      throw SpeciesException(message: 'Especie no encontrada.', statusCode: 404);
    } else {
      throw SpeciesException(
        message: 'Error al eliminar la especie.',
        statusCode: response.statusCode,
      );
    }
  }
}