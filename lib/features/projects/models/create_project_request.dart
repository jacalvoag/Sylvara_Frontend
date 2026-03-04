class CreateProjectRequest {
  final String nombre;
  final String descripcion;
  final String? imagen; // Opcional
  final double? area; // Área de la zona
  final int? unitId; // 1: Metros, 2: Hectáreas

  CreateProjectRequest({
    required this.nombre,
    required this.descripcion,
    this.imagen,
    this.area,
    this.unitId,
  });

  // Convertir a JSON para enviar al backend (camelCase)
  Map<String, dynamic> toJson() {
    return {
      'samplingPlotName': nombre,
      'samplingPlotDescription': descripcion,
      if (imagen != null) 'imageUrl': imagen,
      if (area != null) 'totalArea': area,
      if (unitId != null) 'unitId': unitId,
    };
  }

  // Crear desde JSON (si es necesario)
  factory CreateProjectRequest.fromJson(Map<String, dynamic> json) {
    return CreateProjectRequest(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      imagen: json['imagen'] as String?,
      area: json['area'] as double?,
      unitId: json['unit_id'] as int?,
    );
  }
}
