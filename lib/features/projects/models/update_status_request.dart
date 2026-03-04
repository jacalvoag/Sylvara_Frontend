class UpdateStatusRequest {
  final String samplingPlotStatus;
  final String password;

  UpdateStatusRequest({
    required this.samplingPlotStatus,
    required this.password,
  });

  // Convertir a JSON para enviar al backend (camelCase)
  Map<String, dynamic> toJson() {
    return {
      'samplingPlotStatus': samplingPlotStatus,
      'password': password,
    };
  }

  // Crear desde JSON (si es necesario)
  factory UpdateStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateStatusRequest(
      samplingPlotStatus: json['samplingPlotStatus'] as String,
      password: json['password'] as String,
    );
  }
}
