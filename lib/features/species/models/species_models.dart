/// Modelos para la gestión de especies en zonas de estudio
library;

/// Registro de una especie en una zona de estudio
class SpeciesRecord {
  final int speciesZoneId;
  final int speciesId;
  final String speciesName;
  final String? speciesImageUrl;
  final int functionalTypeId;
  final String functionalTypeName;
  final int individualCount;
  final double heightStratumMin;
  final double heightStratumMax;
  final int unitId;
  final String unitName;
  final int cycleNumber;

  const SpeciesRecord({
    required this.speciesZoneId,
    required this.speciesId,
    required this.speciesName,
    this.speciesImageUrl,
    required this.functionalTypeId,
    required this.functionalTypeName,
    required this.individualCount,
    required this.heightStratumMin,
    required this.heightStratumMax,
    required this.unitId,
    required this.unitName,
    required this.cycleNumber,
  });

  factory SpeciesRecord.fromJson(Map<String, dynamic> json) {
    return SpeciesRecord(
      speciesZoneId: json['speciesZoneId'] as int,
      speciesId: json['speciesId'] as int,
      speciesName: json['speciesName'] as String,
      speciesImageUrl: json['speciesImageUrl'] as String?,
      functionalTypeId: json['functionalTypeId'] as int,
      functionalTypeName: json['functionalTypeName'] as String,
      individualCount: json['individualCount'] as int,
      heightStratumMin: (json['heightStratumMin'] as num).toDouble(),
      heightStratumMax: (json['heightStratumMax'] as num).toDouble(),
      unitId: json['unitId'] as int,
      unitName: json['unitName'] as String,
      cycleNumber: json['cycleNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speciesZoneId': speciesZoneId,
      'speciesId': speciesId,
      'speciesName': speciesName,
      'speciesImageUrl': speciesImageUrl,
      'functionalTypeId': functionalTypeId,
      'functionalTypeName': functionalTypeName,
      'individualCount': individualCount,
      'heightStratumMin': heightStratumMin,
      'heightStratumMax': heightStratumMax,
      'unitId': unitId,
      'unitName': unitName,
      'cycleNumber': cycleNumber,
    };
  }

  @override
  String toString() {
    return 'SpeciesRecord(speciesZoneId: $speciesZoneId, speciesName: $speciesName, '
        'individualCount: $individualCount, cycleNumber: $cycleNumber)';
  }
}

/// Metadatos de paginación para especies
class SpeciesMeta {
  final String? nextCursor;
  final int limit;

  const SpeciesMeta({
    this.nextCursor,
    required this.limit,
  });

  factory SpeciesMeta.fromJson(Map<String, dynamic> json) {
    return SpeciesMeta(
      nextCursor: json['nextCursor'] as String?,
      limit: json['limit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextCursor': nextCursor,
      'limit': limit,
    };
  }

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

/// Respuesta paginada de especies en zona
class PaginatedSpeciesResponse {
  final List<SpeciesRecord> data;
  final SpeciesMeta meta;

  const PaginatedSpeciesResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedSpeciesResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedSpeciesResponse(
      data: (json['data'] as List)
          .map((item) => SpeciesRecord.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: SpeciesMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }

  @override
  String toString() {
    return 'PaginatedSpeciesResponse(data: ${data.length} items, hasMore: ${meta.hasMore})';
  }
}

/// Request para crear o actualizar una especie en zona
class SpeciesRequest {
  final int speciesId;
  final int functionalTypeId;
  final int individualCount;
  final double heightStratumMin;
  final double heightStratumMax;
  final int unitId;

  const SpeciesRequest({
    required this.speciesId,
    required this.functionalTypeId,
    required this.individualCount,
    required this.heightStratumMin,
    required this.heightStratumMax,
    required this.unitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'speciesId': speciesId,
      'functionalTypeId': functionalTypeId,
      'individualCount': individualCount,
      'heightStratumMin': heightStratumMin,
      'heightStratumMax': heightStratumMax,
      'unitId': unitId,
    };
  }

  @override
  String toString() {
    return 'SpeciesRequest(speciesId: $speciesId, individualCount: $individualCount)';
  }
}

/// Respuesta cuando la especie ya existe en el catálogo (200)
class SpeciesExistsInCatalogResponse {
  final String message;
  final int speciesId;
  final String speciesName;
  final int totalIndividuals;

  const SpeciesExistsInCatalogResponse({
    required this.message,
    required this.speciesId,
    required this.speciesName,
    required this.totalIndividuals,
  });

  factory SpeciesExistsInCatalogResponse.fromJson(Map<String, dynamic> json) {
    return SpeciesExistsInCatalogResponse(
      message: json['message'] as String,
      speciesId: json['speciesId'] as int,
      speciesName: json['speciesName'] as String,
      totalIndividuals: json['totalIndividuals'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'speciesId': speciesId,
      'speciesName': speciesName,
      'totalIndividuals': totalIndividuals,
    };
  }

  @override
  String toString() {
    return 'SpeciesExistsInCatalogResponse(message: $message, speciesName: $speciesName)';
  }
}

/// Respuesta cuando la especie ya existe en la zona (409)
class SpeciesExistsInZoneResponse {
  final String message;
  final int speciesZoneId;
  final int speciesId;
  final String speciesName;
  final int individualCount;

  const SpeciesExistsInZoneResponse({
    required this.message,
    required this.speciesZoneId,
    required this.speciesId,
    required this.speciesName,
    required this.individualCount,
  });

  factory SpeciesExistsInZoneResponse.fromJson(Map<String, dynamic> json) {
    return SpeciesExistsInZoneResponse(
      message: json['message'] as String,
      speciesZoneId: json['speciesZoneId'] as int,
      speciesId: json['speciesId'] as int,
      speciesName: json['speciesName'] as String,
      individualCount: json['individualCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'speciesZoneId': speciesZoneId,
      'speciesId': speciesId,
      'speciesName': speciesName,
      'individualCount': individualCount,
    };
  }

  @override
  String toString() {
    return 'SpeciesExistsInZoneResponse(message: $message, speciesName: $speciesName)';
  }
}

/// Resultado del registro de especie (sealed class para type safety)
sealed class RegisterSpeciesResult {}

/// Especie creada exitosamente (201)
class SpeciesCreated extends RegisterSpeciesResult {
  final SpeciesRecord record;

  SpeciesCreated(this.record);
}

/// Especie ya existe en catálogo, solo se actualizó contador (200)
class SpeciesExistsInCatalog extends RegisterSpeciesResult {
  final SpeciesExistsInCatalogResponse response;

  SpeciesExistsInCatalog(this.response);
}

/// Especie ya existe en la zona (409)
class SpeciesExistsInZone extends RegisterSpeciesResult {
  final SpeciesExistsInZoneResponse response;

  SpeciesExistsInZone(this.response);
}

/// Especie en catálogo global del proyecto
class CatalogSpecies {
  final int speciesId;
  final String speciesName;
  final String? speciesImageUrl;
  final String functionalTypeName;
  final int totalIndividuals;

  const CatalogSpecies({
    required this.speciesId,
    required this.speciesName,
    this.speciesImageUrl,
    required this.functionalTypeName,
    required this.totalIndividuals,
  });

  factory CatalogSpecies.fromJson(Map<String, dynamic> json) {
    return CatalogSpecies(
      speciesId: json['speciesId'] as int,
      speciesName: json['speciesName'] as String,
      speciesImageUrl: json['speciesImageUrl'] as String?,
      functionalTypeName: json['functionalTypeName'] as String,
      totalIndividuals: json['totalIndividuals'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speciesId': speciesId,
      'speciesName': speciesName,
      'speciesImageUrl': speciesImageUrl,
      'functionalTypeName': functionalTypeName,
      'totalIndividuals': totalIndividuals,
    };
  }

  @override
  String toString() {
    return 'CatalogSpecies(speciesName: $speciesName, totalIndividuals: $totalIndividuals)';
  }
}

/// Respuesta paginada del catálogo de especies
class PaginatedCatalogResponse {
  final List<CatalogSpecies> data;
  final SpeciesMeta meta;

  const PaginatedCatalogResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedCatalogResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedCatalogResponse(
      data: (json['data'] as List)
          .map((item) => CatalogSpecies.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: SpeciesMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }

  @override
  String toString() {
    return 'PaginatedCatalogResponse(data: ${data.length} items, hasMore: ${meta.hasMore})';
  }
}
