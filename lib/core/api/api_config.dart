class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';

  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String googleStatus = '$baseUrl/auth/google/status';
  static const String googleAuth = '$baseUrl/auth/google';

  static const String snapshot = '$baseUrl/benchmarking/snapshot';
  static const String bigquerySend = '$baseUrl/benchmarking/bigquery/send';
  static const String reset = '$baseUrl/benchmarking/reset';
  static const String csvGenerate = '$baseUrl/benchmarking/csv/generate';
  static const String csvDownload = '$baseUrl/benchmarking/csv/download';
  static const String metrics = '$baseUrl/benchmarking/metrics';
}