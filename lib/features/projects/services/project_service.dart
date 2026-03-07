import 'dart:convert';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';
import 'package:sylvara_frontend/features/projects/models/models.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final _apiClient = ApiClient();

  Future<DashboardResponse> getDashboardData() async {
    final response = await _apiClient.get(ApiConfig.dashboard);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return DashboardResponse.fromJson(data);
    }
    throw ProjectException(
      message: data['message'] ?? 'Error al cargar el dashboard',
      statusCode: response.statusCode,
    );
  }

  Future<PaginatedProjectsResponse> getProjects({
    String? status,
    int? cursor,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConfig.projects(status: status, cursor: cursor, limit: limit),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return PaginatedProjectsResponse.fromJson(data);
    }
    throw ProjectException(
      message: data['message'] ?? 'Error al cargar proyectos',
      statusCode: response.statusCode,
    );
  }

  Future<Plot> createProject(CreateProjectRequest request) async {
    final response = await _apiClient.post(
      '${ApiConfig.baseUrl}/projects',
      body: request.toJson(),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Plot.fromJson(data);
    }
    throw ProjectException(
      message: data['message'] ?? 'Error al crear proyecto',
      statusCode: response.statusCode,
    );
  }

  Future<Plot> updateProject(String id, UpdateProjectRequest request) async {
    final response = await _apiClient.patch(
      ApiConfig.projectById(id),
      body: request.toJson(),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Plot.fromJson(data);
    }
    throw ProjectException(
      message: data['message'] ?? 'Error al actualizar proyecto',
      statusCode: response.statusCode,
    );
  }

  Future<Plot> updateProjectStatus(String id, UpdateStatusRequest request) async {
    final response = await _apiClient.patch(
      ApiConfig.projectStatus(id),
      body: request.toJson(),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Plot.fromJson(data);
    }
    throw ProjectException(
      message: data['message'] ?? 'Error al actualizar estado',
      statusCode: response.statusCode,
    );
  }

  Future<void> deleteProject(String id) async {
    final response = await _apiClient.delete(ApiConfig.projectById(id));

    if (response.statusCode != 204) {
      final data = jsonDecode(response.body);
      throw ProjectException(
        message: data['message'] ?? 'Error al eliminar proyecto',
        statusCode: response.statusCode,
      );
    }
  }
}