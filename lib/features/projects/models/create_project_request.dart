class CreateProjectRequest {
  final String nombre;
  final String? descripcion;
  final double? area;
  final int unitId;

  CreateProjectRequest({
    required this.nombre,
    this.descripcion,
    this.area,
    required this.unitId,
  });

  Map<String, dynamic> toJson() => {
    'samplingPlotName': nombre,
    if (descripcion != null) 'description': descripcion,
    if (area != null) 'totalArea': area,
    'unitId': unitId,
  };
}