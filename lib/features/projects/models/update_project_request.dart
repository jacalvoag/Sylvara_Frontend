class UpdateProjectRequest {
  final String? nombre;
  final String? descripcion;
  final double? area;
  final int? unitId;

  UpdateProjectRequest({
    this.nombre,
    this.descripcion,
    this.area,
    this.unitId,
  });

  Map<String, dynamic> toJson() => {
    if (nombre != null) 'samplingPlotName': nombre,
    if (descripcion != null) 'description': descripcion,
    if (area != null) 'totalArea': area,
    if (unitId != null) 'unitId': unitId,
  };
}