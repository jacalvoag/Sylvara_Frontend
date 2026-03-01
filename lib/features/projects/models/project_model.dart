class Project {
  final String id;
  final String nombre;
  final String descripcion;
  final bool isActive;
  final String imagen;

  const Project({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.isActive,
    required this.imagen,
  });

  // Crear desde JSON (respuesta del backend)
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      isActive: json['is_active'] as bool? ?? true,
      imagen: json['imagen'] as String? ?? 'https://via.placeholder.com/48',
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'is_active': isActive,
      'imagen': imagen,
    };
  }
}
