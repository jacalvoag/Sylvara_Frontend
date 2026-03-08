import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const String _webHost = 'http://localhost:3000/api/v1';
  static const String _mobileHost = 'http://10.0.2.2:3000/api/v1';
  static const String _physicalDeviceHost = '192.168.1.82';

    static String get baseUrl {
    if (kIsWeb) return _webHost;
    // Cambia a _physicalDeviceHost cuando pruebes en dispositivo real
    return _mobileHost;
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get googleStatus => '$baseUrl/auth/google/status';
  static String get googleAuth => '$baseUrl/auth/google';

  static String get dashboard => '$baseUrl/dashboard';

  static String get profile => '$baseUrl/profile';
  static String get profilePassword => '$baseUrl/profile/password';

  static String projects({String? status, int? cursor, int limit = 20}) {
    final params = <String, String>{
      'limit': limit.toString(),
      'status': ?status,
      if (cursor != null) 'cursor': cursor.toString(),
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$baseUrl/projects?$query';
  }

  static String projectById(String id) => '$baseUrl/projects/$id';
  static String projectStatus(String id) => '$baseUrl/projects/$id/status';

  static String get snapshot => '$baseUrl/benchmarking/snapshot';
  static String get bigquerySend => '$baseUrl/benchmarking/bigquery/send';
  static String get reset => '$baseUrl/benchmarking/reset';
  static String get csvGenerate => '$baseUrl/benchmarking/csv/generate';
  static String get csvDownload => '$baseUrl/benchmarking/csv/download';
  static String get metrics => '$baseUrl/benchmarking/metrics';

  static String projectZones(int projectId) => '$baseUrl/projects/$projectId/zones';
  static String projectZoneById(int projectId, int zoneId) => '$baseUrl/projects/$projectId/zones/$zoneId';

  static String speciesInZone(int projectId, int zoneId, {String? cursor, int limit = 20}) {
    final params = <String, String>{
      'limit': limit.toString(),
      'cursor': ?cursor,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$baseUrl/projects/$projectId/zones/$zoneId/species?$query';
  }

  static String speciesCatalog(int projectId, int zoneId, {String? cursor, int limit = 20}) {
    final params = <String, String>{
      'limit': limit.toString(),
      'cursor': ?cursor,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$baseUrl/projects/$projectId/zones/$zoneId/species/catalog?$query';
  }

  static String speciesZoneById(int projectId, int zoneId, int speciesZoneId) =>
      '$baseUrl/projects/$projectId/zones/$zoneId/species/$speciesZoneId';
}