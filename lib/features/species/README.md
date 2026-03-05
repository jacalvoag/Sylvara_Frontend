# Feature: Species (Especies)

Gestión de especies dentro de las zonas de estudio de un proyecto.

## 📁 Estructura

```
lib/features/species/
├── models/
│   ├── species_models.dart      # Modelos de datos
│   ├── species_exception.dart   # Excepciones personalizadas
│   └── models.dart              # Barrel file
├── services/
│   ├── species_service.dart     # Lógica de negocio y API
│   └── services.dart            # Barrel file
└── README.md                    # Documentación
```

## 📦 Modelos

### SpeciesRecord
Representa un registro de especie en una zona de estudio específica.

**Campos:**
- `speciesZoneId` (int): ID único del registro en la zona
- `speciesId` (int): ID de la especie en el catálogo global
- `speciesName` (String): Nombre científico de la especie
- `speciesImageUrl` (String?): URL de la imagen (opcional)
- `functionalTypeId` (int): ID del tipo funcional (1=Árbol, 2=Arbusto, etc.)
- `functionalTypeName` (String): Nombre del tipo funcional
- `individualCount` (int): Número de individuos encontrados
- `heightStratumMin` (double): Altura mínima del estrato (m)
- `heightStratumMax` (double): Altura máxima del estrato (m)
- `unitId` (int): ID de unidad de medida (1=Metros, 2=Centímetros)
- `unitName` (String): Nombre de la unidad
- `cycleNumber` (int): Número del ciclo de monitoreo

### PaginatedSpeciesResponse
Lista paginada de especies en una zona.

**Campos:**
- `data` (List<SpeciesRecord>): Lista de especies
- `meta` (SpeciesMeta): Metadatos de paginación
  - `nextCursor` (String?): Cursor para siguiente página
  - `limit` (int): Límite de resultados
  - `hasMore` (bool): Indica si hay más páginas

### SpeciesRequest
Request para crear o actualizar una especie.

**Campos:**
- `speciesId` (int): ID de la especie del catálogo
- `functionalTypeId` (int): Tipo funcional
- `individualCount` (int): Contador de individuos
- `heightStratumMin` (double): Altura mínima
- `heightStratumMax` (double): Altura máxima
- `unitId` (int): Unidad de medida

### RegisterSpeciesResult (Sealed Class)
Resultado del registro de especie con 3 posibles casos:

#### SpeciesCreated (201)
Especie creada exitosamente.
- `record` (SpeciesRecord): Registro creado

#### SpeciesExistsInCatalog (200)
Especie ya existe en catálogo, solo se actualizó contador.
- `response` (SpeciesExistsInCatalogResponse):
  - `message`: Mensaje descriptivo
  - `speciesId`: ID de la especie
  - `speciesName`: Nombre de la especie
  - `totalIndividuals`: Total acumulado en el proyecto

#### SpeciesExistsInZone (409)
Especie ya existe en la zona.
- `response` (SpeciesExistsInZoneResponse):
  - `message`: Mensaje descriptivo
  - `speciesZoneId`: ID del registro existente
  - `speciesId`: ID de la especie
  - `speciesName`: Nombre de la especie
  - `individualCount`: Individuos actuales en la zona

### CatalogSpecies
Especie en el catálogo global del proyecto.

**Campos:**
- `speciesId` (int): ID único de la especie
- `speciesName` (String): Nombre científico
- `speciesImageUrl` (String?): URL de imagen (opcional)
- `functionalTypeName` (String): Tipo funcional
- `totalIndividuals` (int): Total de individuos en todas las zonas

### PaginatedCatalogResponse
Lista paginada del catálogo de especies.

**Campos:**
- `data` (List<CatalogSpecies>): Lista de especies
- `meta` (SpeciesMeta): Metadatos de paginación

## 🔧 Servicio

### SpeciesService (Singleton)

**Acceso:**
```dart
final service = SpeciesService.instance;
```

#### Métodos

##### getSpeciesInZone
Obtiene especies de una zona específica con paginación.

```dart
Future<PaginatedSpeciesResponse> getSpeciesInZone(
  int projectId,
  int zoneId, {
  String? cursor,
  int limit = 20,
})
```

**Endpoint:** `GET /projects/:projectId/zones/:zoneId/species`

**Parámetros:**
- `projectId`: ID del proyecto
- `zoneId`: ID de la zona
- `cursor`: Cursor para paginación (opcional)
- `limit`: Límite de resultados (default: 20)

**Respuestas:**
- 200: PaginatedSpeciesResponse
- 404: Zona no encontrada
- 500: Error del servidor

**Ejemplo:**
```dart
try {
  final response = await SpeciesService.instance.getSpeciesInZone(
    projectId: 1,
    zoneId: 5,
    limit: 10,
  );
  
  print('Especies encontradas: ${response.data.length}');
  print('Hay más páginas: ${response.meta.hasMore}');
  
  // Cargar siguiente página
  if (response.meta.hasMore) {
    final nextPage = await SpeciesService.instance.getSpeciesInZone(
      projectId: 1,
      zoneId: 5,
      cursor: response.meta.nextCursor,
    );
  }
} on SpeciesException catch (e) {
  print('Error: ${e.message}');
}
```

##### getSpeciesCatalog
Obtiene el catálogo de especies del proyecto.

```dart
Future<PaginatedCatalogResponse> getSpeciesCatalog(
  int projectId,
  int zoneId, {
  String? cursor,
  int limit = 20,
})
```

**Endpoint:** `GET /projects/:projectId/zones/:zoneId/catalog`

**Ejemplo:**
```dart
final catalog = await SpeciesService.instance.getSpeciesCatalog(
  projectId: 1,
  zoneId: 5,
);

for (var species in catalog.data) {
  print('${species.speciesName}: ${species.totalIndividuals} individuos');
}
```

##### registerSpecies
Registra una nueva especie en la zona.

⚠️ **Importante:** Este método retorna un `RegisterSpeciesResult` (sealed class) con 3 posibles resultados.

```dart
Future<RegisterSpeciesResult> registerSpecies(
  int projectId,
  int zoneId,
  SpeciesRequest request,
)
```

**Endpoint:** `POST /projects/:projectId/zones/:zoneId/species`

**Escenarios:**
1. **201 Created** → `SpeciesCreated(record)`
2. **200 OK** → `SpeciesExistsInCatalog(response)` - Ya existe en catálogo
3. **409 Conflict** → `SpeciesExistsInZone(response)` - Ya existe en zona

**Ejemplo con Pattern Matching:**
```dart
final request = SpeciesRequest(
  speciesId: 101,
  functionalTypeId: 1,
  individualCount: 15,
  heightStratumMin: 10.0,
  heightStratumMax: 25.0,
  unitId: 1,
);

final result = await SpeciesService.instance.registerSpecies(
  projectId: 1,
  zoneId: 5,
  request,
);

// Pattern matching con switch exhaustivo (Dart 3)
switch (result) {
  case SpeciesCreated(:var record):
    print('✅ Especie creada: ${record.speciesName}');
    print('ID: ${record.speciesZoneId}');
    
  case SpeciesExistsInCatalog(:var response):
    print('ℹ️ ${response.message}');
    print('Total en proyecto: ${response.totalIndividuals}');
    
  case SpeciesExistsInZone(:var response):
    print('⚠️ ${response.message}');
    print('Individuos actuales: ${response.individualCount}');
}
```

**Validaciones:**
- individualCount > 0
- heightStratumMin >= 0
- heightStratumMax > heightStratumMin

**Excepciones:**
- 422: Datos inválidos
- 500: Error del servidor

##### updateSpeciesRecord
Actualiza un registro existente de especie.

```dart
Future<SpeciesRecord> updateSpeciesRecord(
  int projectId,
  int zoneId,
  int speciesZoneId,
  SpeciesRequest request,
)
```

**Endpoint:** `PATCH /projects/:projectId/zones/:zoneId/species/:speciesZoneId`

**Ejemplo:**
```dart
final updated = await SpeciesService.instance.updateSpeciesRecord(
  projectId: 1,
  zoneId: 5,
  speciesZoneId: 12,
  SpeciesRequest(
    speciesId: 101,
    functionalTypeId: 1,
    individualCount: 20, // Actualizado de 15 a 20
    heightStratumMin: 10.0,
    heightStratumMax: 25.0,
    unitId: 1,
  ),
);

print('Actualizado: ${updated.speciesName}');
```

**Respuestas:**
- 200: SpeciesRecord actualizado
- 404: Registro no encontrado
- 422: Datos inválidos

##### deleteSpeciesRecord
Elimina un registro de especie.

```dart
Future<void> deleteSpeciesRecord(
  int projectId,
  int zoneId,
  int speciesZoneId,
)
```

**Endpoint:** `DELETE /projects/:projectId/zones/:zoneId/species/:speciesZoneId`

**Ejemplo:**
```dart
await SpeciesService.instance.deleteSpeciesRecord(
  projectId: 1,
  zoneId: 5,
  speciesZoneId: 12,
);
print('Especie eliminada');
```

**Respuestas:**
- 204: Eliminado exitosamente
- 404: Registro no encontrado

## 🔍 Manejo de Errores

### SpeciesException
Todos los métodos pueden lanzar `SpeciesException`:

```dart
try {
  await SpeciesService.instance.deleteSpeciesRecord(1, 5, 999);
} on SpeciesException catch (e) {
  if (e.statusCode == 404) {
    print('Especie no encontrada');
  } else {
    print('Error ${e.statusCode}: ${e.message}');
  }
}
```

**Códigos comunes:**
- 404: Recurso no encontrado
- 422: Datos inválidos
- 500: Error del servidor

## 📊 Mock Data

El servicio incluye datos mock para desarrollo:

### Especies en zona:
- Quercus robur (Árbol, 15 individuos)
- Pinus sylvestris (Árbol, 22 individuos)
- Rubus fruticosus (Arbusto, 45 individuos)

### Catálogo del proyecto:
- Quercus robur (45 individuos totales)
- Pinus sylvestris (68 individuos totales)
- Rubus fruticosus (120 individuos totales)
- Fagus sylvatica (32 individuos totales)
- Hedera helix (89 individuos totales)

## 🚀 Estado de Implementación

- ✅ Modelos completos con JSON serialization
- ✅ Sealed class para resultado de registro (type-safe)
- ✅ Servicio con 5 métodos CRUD
- ✅ Mock data para desarrollo
- ✅ Manejo de paginación cursor-based
- ✅ Validaciones de negocio
- ✅ Manejo de errores con excepciones tipadas
- ⏳ UI/Screens (pendiente)
- ⏳ Widgets (pendiente)

## 📝 Notas Técnicas

### Pattern Matching en registerSpecies
El uso de sealed classes permite pattern matching exhaustivo en Dart 3:

```dart
// El compilador garantiza que se manejan todos los casos
final result = await service.registerSpecies(...);

switch (result) {
  case SpeciesCreated(): // Manejado
  case SpeciesExistsInCatalog(): // Manejado
  case SpeciesExistsInZone(): // Manejado
  // Si falta algún caso, error de compilación
}
```

### Alternativa con if/else:
```dart
if (result is SpeciesCreated) {
  final record = result.record;
  // ...
} else if (result is SpeciesExistsInCatalog) {
  final response = result.response;
  // ...
} else if (result is SpeciesExistsInZone) {
  final response = result.response;
  // ...
}
```

### Paginación
Usa cursor-based pagination:
1. Primera carga: sin cursor
2. Siguientes cargas: usar `meta.nextCursor`
3. Fin de datos: `meta.hasMore == false`

## 🔗 Integración con otras features

- **Zones**: Las especies pertenecen a zonas de estudio
- **Projects**: El catálogo de especies es por proyecto
- **Índices de Biodiversidad**: Se calculan a partir de los datos de especies
