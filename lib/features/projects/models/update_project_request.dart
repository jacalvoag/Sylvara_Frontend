class UpdateProjectRequest {
  final String nombre;
  final String descripcion;
  final String? imagen; // Opcional
  final double? area; // Área de la zona
  final int? unitId; // 1: Metros, 2: Hectáreas

  UpdateProjectRequest({
    required this.nombre,
    required this.descripcion,
    this.imagen,
    this.area,
    this.unitId,
  });

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      if (imagen != null) 'imagen': imagen,
      if (area != null) 'area': area,
      if (unitId != null) 'unit_id': unitId,
    };
  }

  // Crear desde JSON (si es necesario)
  factory UpdateProjectRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProjectRequest(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      imagen: json['imagen'] as String?,
      area: json['area'] as double?,
      unitId: json['unit_id'] as int?,
    );
  }
}
