import 'dart:convert';
import 'package:sylvara_frontend/core/api/api_client.dart';
import 'package:sylvara_frontend/core/api/api_config.dart';
import 'package:sylvara_frontend/features/benchmarking/models/models.dart';

class BenchmarkingService {
  static final BenchmarkingService _instance = BenchmarkingService._internal();
  factory BenchmarkingService() => _instance;
  BenchmarkingService._internal();

  final _apiClient = ApiClient();

  Future<bool> isGoogleConnected() async {
    final response = await _apiClient.get(ApiConfig.googleStatus);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['connected'] == true;
    }
    return false;
  }

  String getGoogleAuthUrl(String jwtToken) {
    return '${ApiConfig.googleAuth}?token=$jwtToken';
  }

  Future<List<SnapshotRow>> getSnapshot() async {
    final response = await _apiClient.get(ApiConfig.snapshot);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((row) => SnapshotRow.fromJson(row)).toList();
    }
    throw Exception('Error al obtener snapshot: ${response.body}');
  }

  Future<Map<String, dynamic>> sendToBigQuery() async {
    final response = await _apiClient.post(ApiConfig.bigquerySend);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al enviar a BigQuery: ${response.body}');
  }

  Future<void> resetStatistics() async {
    final response = await _apiClient.post(ApiConfig.reset);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al resetear estadísticas: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> generateCsv() async {
    final response = await _apiClient.get(ApiConfig.csvGenerate);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al generar CSV: ${response.body}');
  }

  Future<List<dynamic>> getMetrics() async {
    final response = await _apiClient.get(ApiConfig.metrics);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener métricas: ${response.body}');
  }

  Future<List<int>> downloadCsvBytes() async {
    final response = await _apiClient.get(ApiConfig.csvDownload);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Error al descargar CSV: ${response.body}');
  }
}