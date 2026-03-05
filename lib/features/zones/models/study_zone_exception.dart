class StudyZoneException implements Exception {
  final String message;
  final int statusCode;

  StudyZoneException({
    required this.message,
    this.statusCode = 500,
  });

  @override
  String toString() {
    return 'StudyZoneException($statusCode): $message';
  }
}
