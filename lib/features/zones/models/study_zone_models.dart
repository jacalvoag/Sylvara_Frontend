/// Índices de biodiversidad
class Indices {
  final double shannon;
  final double simpson;
  final double margalef;
  final double pielou;

  Indices({
    required this.shannon,
    required this.simpson,
    required this.margalef,
    required this.pielou,
  });

  factory Indices.fromJson(Map<String, dynamic> json) {
    return Indices(
      shannon: (json['shannon'] as num).toDouble(),
      simpson: (json['simpson'] as num).toDouble(),
      margalef: (json['margalef'] as num).toDouble(),
      pielou: (json['pielou'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shannon': shannon,
      'simpson': simpson,
      'margalef': margalef,
      'pielou': pielou,
    };
  }

  @override
  String toString() {
    return 'Indices(shannon: $shannon, simpson: $simpson, margalef: $margalef, pielou: $pielou)';
  }
}

/// Contadores de especies e individuos
class Counts {
  final int speciesRichness;
  final int totalIndividuals;

  Counts({
    required this.speciesRichness,
    required this.totalIndividuals,
  });

  factory Counts.fromJson(Map<String, dynamic> json) {
    return Counts(
      speciesRichness: json['speciesRichness'] as int,
      totalIndividuals: json['totalIndividuals'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speciesRichness': speciesRichness,
      'totalIndividuals': totalIndividuals,
    };
  }

  @override
  String toString() {
    return 'Counts(speciesRichness: $speciesRichness, totalIndividuals: $totalIndividuals)';
  }
}

/// Métricas globales del proyecto
class GlobalMetrics {
  final Indices indices;
  final Counts counts;

  GlobalMetrics({
    required this.indices,
    required this.counts,
  });

  factory GlobalMetrics.fromJson(Map<String, dynamic> json) {
    return GlobalMetrics(
      indices: Indices.fromJson(json['indices'] as Map<String, dynamic>),
      counts: Counts.fromJson(json['counts'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'indices': indices.toJson(),
      'counts': counts.toJson(),
    };
  }

  @override
  String toString() {
    return 'GlobalMetrics(indices: $indices, counts: $counts)';
  }
}

/// Zona de estudio individual
class StudyZone {
  final int studyZoneId;
  final String nameStudyZone;
  final double subArea;
  final int unitId;
  final String unitName;
  final int cycleNumber;
  final Indices indices;
  final Counts counts;

  StudyZone({
    required this.studyZoneId,
    required this.nameStudyZone,
    required this.subArea,
    required this.unitId,
    required this.unitName,
    required this.cycleNumber,
    required this.indices,
    required this.counts,
  });

  factory StudyZone.fromJson(Map<String, dynamic> json) {
    return StudyZone(
      studyZoneId: json['studyZoneId'] as int,
      nameStudyZone: json['nameStudyZone'] as String,
      subArea: (json['subArea'] as num).toDouble(),
      unitId: json['unitId'] as int,
      unitName: json['unitName'] as String,
      cycleNumber: json['cycleNumber'] as int,
      indices: Indices.fromJson(json['indices'] as Map<String, dynamic>),
      counts: Counts.fromJson(json['counts'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studyZoneId': studyZoneId,
      'nameStudyZone': nameStudyZone,
      'subArea': subArea,
      'unitId': unitId,
      'unitName': unitName,
      'cycleNumber': cycleNumber,
      'indices': indices.toJson(),
      'counts': counts.toJson(),
    };
  }

  @override
  String toString() {
    return 'StudyZone(id: $studyZoneId, name: $nameStudyZone, area: $subArea $unitName, cycle: $cycleNumber)';
  }
}

/// Respuesta del GET /projects/:id/zones
class ProjectZonesResponse {
  final int samplingPlotId;
  final int cycleNumber;
  final GlobalMetrics globalMetrics;
  final List<StudyZone> zones;

  ProjectZonesResponse({
    required this.samplingPlotId,
    required this.cycleNumber,
    required this.globalMetrics,
    required this.zones,
  });

  factory ProjectZonesResponse.fromJson(Map<String, dynamic> json) {
    return ProjectZonesResponse(
      samplingPlotId: json['samplingPlotId'] as int,
      cycleNumber: json['cycleNumber'] as int,
      globalMetrics: GlobalMetrics.fromJson(
        json['globalMetrics'] as Map<String, dynamic>,
      ),
      zones: (json['zones'] as List<dynamic>)
          .map((zone) => StudyZone.fromJson(zone as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'samplingPlotId': samplingPlotId,
      'cycleNumber': cycleNumber,
      'globalMetrics': globalMetrics.toJson(),
      'zones': zones.map((zone) => zone.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ProjectZonesResponse(projectId: $samplingPlotId, cycle: $cycleNumber, zones: ${zones.length})';
  }
}

/// Request para crear o actualizar una zona de estudio
class StudyZoneRequest {
  final String nameStudyZone;
  final double subArea;
  final int unitId;

  StudyZoneRequest({
    required this.nameStudyZone,
    required this.subArea,
    required this.unitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nameStudyZone': nameStudyZone,
      'subArea': subArea,
      'unitId': unitId,
    };
  }

  factory StudyZoneRequest.fromJson(Map<String, dynamic> json) {
    return StudyZoneRequest(
      nameStudyZone: json['nameStudyZone'] as String,
      subArea: (json['subArea'] as num).toDouble(),
      unitId: json['unitId'] as int,
    );
  }

  @override
  String toString() {
    return 'StudyZoneRequest(name: $nameStudyZone, area: $subArea, unitId: $unitId)';
  }
}
