class UpdateStatusRequest {
  final String samplingPlotStatus;
  final String password;

  UpdateStatusRequest({
    required this.samplingPlotStatus,
    required this.password,
  });

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'sampling_plot_status': samplingPlotStatus,
      'password': password,
    };
  }

  // Crear desde JSON (si es necesario)
  factory UpdateStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateStatusRequest(
      samplingPlotStatus: json['sampling_plot_status'] as String,
      password: json['password'] as String,
    );
  }
}
