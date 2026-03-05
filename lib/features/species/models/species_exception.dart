/// Excepción personalizada para operaciones de especies
class SpeciesException implements Exception {
  final String message;
  final int statusCode;

  const SpeciesException({
    required this.message,
    this.statusCode = 500,
  });

  @override
  String toString() => 'SpeciesException($statusCode): $message';
}
