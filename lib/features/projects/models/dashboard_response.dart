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

  /// Crear desde JSON (respuesta del backend)
  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      user: DashboardUser.fromJson(json['user'] as Map<String, dynamic>),
      summary: DashboardSummary.fromJson(json['summary'] as Map<String, dynamic>),
      latestPlots: (json['latest_plots'] as List<dynamic>)
          .map((plot) => Plot.fromJson(plot as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir a JSON
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
  final int totalHistoricalPlots; // Total de proyectos históricos
  final int currentMonthPlots;    // Proyectos del mes actual

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
  final String id;
  final String name;
  final String description;
  final String status;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Plot({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Verificar si el proyecto está activo
  bool get isActive => status.toLowerCase() == 'active' || status.toLowerCase() == 'activo';

  /// Convertir Plot a Project (para compatibilidad con widgets existentes)
  Project toProject() {
    return Project(
      id: id,
      nombre: name,
      descripcion: description,
      isActive: isActive,
      imagen: imageUrl ?? '',
    );
  }
}
