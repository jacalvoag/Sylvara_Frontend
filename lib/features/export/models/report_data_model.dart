class SpeciesRecordReport {
  final String speciesName;
  final String functionalTypeName;
  final int individualCount;
  final double heightMin;
  final double heightMax;
  final String unitName;

  const SpeciesRecordReport({
    required this.speciesName,
    required this.functionalTypeName,
    required this.individualCount,
    required this.heightMin,
    required this.heightMax,
    required this.unitName,
  });

  factory SpeciesRecordReport.fromJson(Map<String, dynamic> json) {
    return SpeciesRecordReport(
      speciesName: json['speciesName'] as String? ?? '',
      functionalTypeName: json['functionalTypeName'] as String? ?? '',
      individualCount: json['individualCount'] as int? ?? 0,
      heightMin: (json['heightMin'] as num?)?.toDouble() ?? 0,
      heightMax: (json['heightMax'] as num?)?.toDouble() ?? 0,
      unitName: json['unitName'] as String? ?? '',
    );
  }
}

class ZoneBiodiversityReport {
  final int zoneId;
  final String zoneName;
  final double subArea;
  final String unitName;
  final int cycleNumber;
  final int speciesRichness;
  final int totalIndividuals;
  final ReportIndices indices;
  final List<SpeciesRecordReport> speciesRecords;

  const ZoneBiodiversityReport({
    required this.zoneId,
    required this.zoneName,
    required this.subArea,
    required this.unitName,
    required this.cycleNumber,
    required this.speciesRichness,
    required this.totalIndividuals,
    required this.indices,
    required this.speciesRecords,
  });

  factory ZoneBiodiversityReport.fromJson(Map<String, dynamic> json) {
    final indicesJson = json['indices'] as Map<String, dynamic>? ?? {};
    final recordsList = json['speciesRecords'] as List<dynamic>? ?? [];
    return ZoneBiodiversityReport(
      zoneId: json['zoneId'] as int? ?? 0,
      zoneName: json['zoneName'] as String? ?? '',
      subArea: (json['subArea'] as num?)?.toDouble() ?? 0,
      unitName: json['unitName'] as String? ?? '',
      cycleNumber: json['cycleNumber'] as int? ?? 1,
      speciesRichness: json['speciesRichness'] as int? ?? 0,
      totalIndividuals: json['totalIndividuals'] as int? ?? 0,
      indices: ReportIndices.fromJson(indicesJson),
      speciesRecords: recordsList
          .map((r) => SpeciesRecordReport.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReportIndices {
  final double shannon;
  final double simpson;
  final double margalef;
  final double pielou;

  const ReportIndices({
    required this.shannon,
    required this.simpson,
    required this.margalef,
    required this.pielou,
  });

  factory ReportIndices.fromJson(Map<String, dynamic> json) {
    return ReportIndices(
      shannon: (json['shannon'] as num?)?.toDouble() ?? 0,
      simpson: (json['simpson'] as num?)?.toDouble() ?? 0,
      margalef: (json['margalef'] as num?)?.toDouble() ?? 0,
      pielou: (json['pielou'] as num?)?.toDouble() ?? 0,
    );
  }
}

class GlobalMetricsReport {
  final int speciesRichness;
  final int totalIndividuals;
  final ReportIndices indices;

  const GlobalMetricsReport({
    required this.speciesRichness,
    required this.totalIndividuals,
    required this.indices,
  });

  factory GlobalMetricsReport.fromJson(Map<String, dynamic> json) {
    final indicesJson = json['indices'] as Map<String, dynamic>? ?? {};
    return GlobalMetricsReport(
      speciesRichness: json['speciesRichness'] as int? ?? 0,
      totalIndividuals: json['totalIndividuals'] as int? ?? 0,
      indices: ReportIndices.fromJson(indicesJson),
    );
  }
}

class ReportDataModel {
  final int projectId;
  final String projectName;
  final String? description;
  final double totalArea;
  final String unitName;
  final String status;
  final int cycleNumber;
  final DateTime? startDate;
  final DateTime? endDate;
  final String researcherName;
  final String researcherLastname;
  final GlobalMetricsReport globalMetrics;
  final List<ZoneBiodiversityReport> zonesDetails;

  const ReportDataModel({
    required this.projectId,
    required this.projectName,
    this.description,
    required this.totalArea,
    required this.unitName,
    required this.status,
    required this.cycleNumber,
    this.startDate,
    this.endDate,
    required this.researcherName,
    required this.researcherLastname,
    required this.globalMetrics,
    required this.zonesDetails,
  });

  factory ReportDataModel.fromJson(Map<String, dynamic> json) {
    final globalJson = json['globalMetrics'] as Map<String, dynamic>? ?? {};
    final zonesList = json['zonesDetails'] as List<dynamic>? ?? [];
    return ReportDataModel(
      projectId: json['projectId'] as int? ?? 0,
      projectName: json['projectName'] as String? ?? '',
      description: json['description'] as String?,
      totalArea: (json['totalArea'] as num?)?.toDouble() ?? 0,
      unitName: json['unitName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      cycleNumber: json['cycleNumber'] as int? ?? 1,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      researcherName: json['researcherName'] as String? ?? '',
      researcherLastname: json['researcherLastname'] as String? ?? '',
      globalMetrics: GlobalMetricsReport.fromJson(globalJson),
      zonesDetails: zonesList
          .map((z) => ZoneBiodiversityReport.fromJson(z as Map<String, dynamic>))
          .toList(),
    );
  }

  String get researcherFullName => '$researcherName $researcherLastname';
  bool get isActive => status.toLowerCase() == 'active';
}
