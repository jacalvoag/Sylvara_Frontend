import 'project_model.dart';

/// Modelo para el Dashboard del usuario
/// Contrato: GET /dashboard
class DashboardResponse {
  final DashboardUser user;
  final DashboardSummary summary;
  final List<Plot> latestPlots;

  DashboardResponse({
    required this.user,
    required this.summary,
    required this.latestPlots,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final summary = json['summary'] as Map<String, dynamic>;
    final plots = json['latestPlots'] as List<dynamic>? ?? [];

    return DashboardResponse(
      user: DashboardUser(
        userName: user['userName'] as String? ?? '',
        profilePictureUrl: user['profilePictureUrl'] as String?,
      ),
      summary: DashboardSummary(
        totalHistoricalPlots: summary['totalHistoricalPlots'] as int? ?? 0,
        currentMonthPlots: summary['currentMonthPlots'] as int? ?? 0,
      ),
      latestPlots: plots.map((plot) {
        final p = plot as Map<String, dynamic>;
        return Plot(
          samplingPlotId: p['id'] as int,
          samplingPlotName: p['name'] as String? ?? '',
          description: p['description'] as String?,         // ← mapeado
          totalArea: (p['totalArea'] as num?)?.toDouble(),
          unitName: p['areaUnit'] as String?,
          samplingPlotStatus: p['status'] as String? ?? 'active',
          startDate: p['startDate'] != null
              ? DateTime.tryParse(p['startDate'].toString())
              : null,
        );
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'summary': summary.toJson(),
      'latest_plots': latestPlots.map((plot) => plot.toJson()).toList(),
    };
  }
}

/// Usuario del Dashboard
class DashboardUser {
  final String userName;
  final String? profilePictureUrl;

  DashboardUser({
    required this.userName,
    this.profilePictureUrl,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      userName: json['user_name'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

/// Resumen de proyectos del Dashboard
class DashboardSummary {
  final int totalHistoricalPlots;
  final int currentMonthPlots;

  DashboardSummary({
    required this.totalHistoricalPlots,
    required this.currentMonthPlots,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalHistoricalPlots: json['total_historical_plots'] as int,
      currentMonthPlots: json['current_month_plots'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_historical_plots': totalHistoricalPlots,
      'current_month_plots': currentMonthPlots,
    };
  }
}

/// Proyecto (Plot) individual
class Plot {
  final int samplingPlotId;
  final String samplingPlotName;
  final String? description;
  final double? totalArea;
  final int? unitId;
  final String? unitName;
  final String samplingPlotStatus;
  final int? currentCycleNumber;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imageUrl;

  Plot({
    required this.samplingPlotId,
    required this.samplingPlotName,
    this.description,
    this.totalArea,
    this.unitId,
    this.unitName,
    required this.samplingPlotStatus,
    this.currentCycleNumber,
    this.startDate,
    this.endDate,
    this.imageUrl,
  });

  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      samplingPlotId: json['samplingPlotId'] as int,
      samplingPlotName: json['samplingPlotName'] as String,
      description: json['description'] as String?,
      totalArea: (json['totalArea'] as num?)?.toDouble(),
      unitId: json['unitId'] as int?,
      unitName: json['unitName'] as String?,
      samplingPlotStatus: json['samplingPlotStatus'] as String,
      currentCycleNumber: json['currentCycleNumber'] as int?,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'samplingPlotId': samplingPlotId,
      'samplingPlotName': samplingPlotName,
      'description': description,
      'totalArea': totalArea,
      'unitId': unitId,
      'unitName': unitName,
      'samplingPlotStatus': samplingPlotStatus,
      'currentCycleNumber': currentCycleNumber,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  bool get isActive =>
      samplingPlotStatus.toLowerCase() == 'active' ||
      samplingPlotStatus.toLowerCase() == 'activo';

  /// Convierte Plot a Project usando la descripción real del campo
  Project toProject() {
    return Project(
      id: samplingPlotId.toString(),
      nombre: samplingPlotName,
      descripcion: description ?? '',   // ← usa el campo real
      isActive: isActive,
      imagen: imageUrl ?? '',
    );
  }

  String get id => samplingPlotId.toString();
  String get name => samplingPlotName;
  String get status => samplingPlotStatus;
  // ELIMINADO: el getter `description` que ocultaba el campo del constructor
}

/// Respuesta paginada de proyectos
class PaginatedProjectsResponse {
  final List<Plot> data;
  final PaginationMeta meta;

  PaginatedProjectsResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedProjectsResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedProjectsResponse(
      data: (json['data'] as List<dynamic>)
          .map((plot) => Plot.fromJson(plot as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((plot) => plot.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

/// Metadatos de paginación
class PaginationMeta {
  final int? nextCursor;
  final int limit;

  PaginationMeta({
    this.nextCursor,
    required this.limit,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      nextCursor: json['nextCursor'] as int?,
      limit: json['limit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextCursor': nextCursor,
      'limit': limit,
    };
  }

  bool get hasMore => nextCursor != null;
}