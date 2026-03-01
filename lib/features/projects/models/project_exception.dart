class ProjectException implements Exception {
  final String message;
  final int statusCode;

  ProjectException({
    required this.message,
    this.statusCode = 500,
  });

  @override
  String toString() {
    return 'ProjectException($statusCode): $message';
  }
}
