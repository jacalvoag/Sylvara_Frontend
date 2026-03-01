class CreateProjectRequest {
  final String nombre;
  final String descripcion;
  final String? imagen; // Opcional

  CreateProjectRequest({
    required this.nombre,
    required this.descripcion,
    this.imagen,
  });

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      if (imagen != null) 'imagen': imagen,
    };
  }

  // Crear desde JSON (si es necesario)
  factory CreateProjectRequest.fromJson(Map<String, dynamic> json) {
    return CreateProjectRequest(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      imagen: json['imagen'] as String?,
    );
  }
}
