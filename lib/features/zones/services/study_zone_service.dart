import 'dart:convert';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';
import 'package:sylvara_frontend/features/zones/models/models.dart';

class StudyZoneService {
  static final StudyZoneService _instance = StudyZoneService._internal();
  factory StudyZoneService() => _instance;
  StudyZoneService._internal();
  static StudyZoneService get instance => _instance;

  final _client = ApiClient();

  Future<ProjectZonesResponse> getProjectZones(int projectId) async {
    final response = await _client.get(ApiConfig.projectZones(projectId));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ProjectZonesResponse.fromJson(json);
    } else if (response.statusCode == 404) {
      throw StudyZoneException(
        message: 'Proyecto no encontrado.',
        statusCode: 404,
      );
    } else {
      throw StudyZoneException(
        message: 'Error al obtener las zonas.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<StudyZone> createStudyZone(int projectId, StudyZoneRequest request) async {
    final response = await _client.post(
      ApiConfig.projectZones(projectId),
      body: request.toJson(),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return StudyZone.fromJson(json);
    } else if (response.statusCode == 422) {
      throw StudyZoneException(
        message: 'La sub-área excede el área total del proyecto.',
        statusCode: 422,
      );
    } else if (response.statusCode == 404) {
      throw StudyZoneException(
        message: 'Proyecto no encontrado.',
        statusCode: 404,
      );
    } else {
      throw StudyZoneException(
        message: 'Error al crear la zona.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<StudyZone> updateStudyZone(int projectId, int zoneId, StudyZoneRequest request) async {
    final response = await _client.patch(
      ApiConfig.projectZoneById(projectId, zoneId),
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return StudyZone.fromJson(json);
    } else if (response.statusCode == 422) {
      throw StudyZoneException(
        message: 'La sub-área excede el área total del proyecto.',
        statusCode: 422,
      );
    } else if (response.statusCode == 404) {
      throw StudyZoneException(
        message: 'Zona no encontrada.',
        statusCode: 404,
      );
    } else {
      throw StudyZoneException(
        message: 'Error al actualizar la zona.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteStudyZone(int projectId, int zoneId) async {
    final response = await _client.delete(
      ApiConfig.projectZoneById(projectId, zoneId),
    );

    if (response.statusCode == 204) return;

    if (response.statusCode == 404) {
      throw StudyZoneException(
        message: 'Zona no encontrada.',
        statusCode: 404,
      );
    } else {
      throw StudyZoneException(
        message: 'Error al eliminar la zona.',
        statusCode: response.statusCode,
      );
    }
  }
}