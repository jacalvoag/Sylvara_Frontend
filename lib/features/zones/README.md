# Zonas de Estudio - Feature Module

Este módulo gestiona las Zonas de Estudio dentro de los proyectos de muestreo.

## Estructura

```
zones/
├── models/
│   ├── study_zone_models.dart      # Modelos de datos
│   ├── study_zone_exception.dart   # Excepciones personalizadas
│   └── models.dart                 # Barrel file
├── services/
│   ├── study_zone_service.dart     # Lógica de negocio y API
│   └── services.dart               # Barrel file
├── widgets/
│   ├── biodiversity_chart.dart     # Gráficos de biodiversidad
│   └── widgets.dart                # Barrel file
└── screens/                        # (Pendiente) Vistas de UI
```

## Modelos de Datos

### `Indices`
Índices de biodiversidad para análisis ecológico:
- `shannon`: Índice de Shannon (diversidad)
- `simpson`: Índice de Simpson (dominancia)
- `margalef`: Índice de Margalef (riqueza)
- `pielou`: Índice de Pielou (equidad)

### `Counts`
Contadores de especies e individuos:
- `speciesRichness`: Número total de especies
- `totalIndividuals`: Número total de individuos

### `GlobalMetrics`
Métricas globales del proyecto que contiene `Indices` y `Counts`.

### `StudyZone`
Zona de estudio individual con:
- `studyZoneId`: ID único
- `nameStudyZone`: Nombre de la zona
- `subArea`: Área de la subzona
- `unitId`: ID de la unidad de medida
- `unitName`: Nombre de la unidad (Metros/Hectáreas)
- `cycleNumber`: Número de ciclo
- `indices`: Índices de biodiversidad
- `counts`: Contadores

### `ProjectZonesResponse`
Respuesta del GET con:
- `samplingPlotId`: ID del proyecto
- `cycleNumber`: Número de ciclo
- `globalMetrics`: Métricas globales calculadas
- `zones`: Lista de zonas de estudio

### `StudyZoneRequest`
Request para POST/PATCH con:
- `nameStudyZone`: Nombre de la zona
- `subArea`: Área de la subzona
- `unitId`: ID de la unidad de medida

## Servicio

### `StudyZoneService`
Servicio Singleton que gestiona las operaciones CRUD:

#### Métodos

**`getProjectZones(int projectId)`**
- GET /projects/:id/zones
- Retorna: `ProjectZonesResponse`
- Errores: 404 (proyecto no encontrado)

**`createStudyZone(int projectId, StudyZoneRequest request)`**
- POST /projects/:id/zones
- Retorna: `StudyZone`
- Errores: 
  - 400 (datos inválidos)
  - 404 (proyecto no encontrado)
  - 422 (área excedida > 5000)

**`updateStudyZone(int projectId, int zoneId, StudyZoneRequest request)`**
- PATCH /projects/:id/zones/:zoneId
- Retorna: `StudyZone`
- Errores:
  - 400 (datos inválidos)
  - 404 (proyecto/zona no encontrada)
  - 422 (área excedida > 5000)

**`deleteStudyZone(int projectId, int zoneId)`**
- DELETE /projects/:id/zones/:zoneId
- Retorna: `void`
- Errores: 404 (proyecto/zona no encontrada)

## Uso

```dart
import 'package:sylvara_frontend/features/zones/models/models.dart';
import 'package:sylvara_frontend/features/zones/services/services.dart';

final service = StudyZoneService();

// Obtener zonas de un proyecto
try {
  final response = await service.getProjectZones(1);
  print('Proyecto ${response.samplingPlotId} - Ciclo ${response.cycleNumber}');
  print('Total de zonas: ${response.zones.length}');
  print('Shannon Global: ${response.globalMetrics.indices.shannon}');
  
  for (final zone in response.zones) {
    print('${zone.nameStudyZone}: ${zone.subArea} ${zone.unitName}');
  }
} on StudyZoneException catch (e) {
  print('Error ${e.statusCode}: ${e.message}');
}

// Crear una zona
try {
  final request = StudyZoneRequest(
    nameStudyZone: 'Zona Oeste',
    subArea: 150.0,
    unitId: 2, // 1: Metros, 2: Hectáreas
  );
  
  final newZone = await service.createStudyZone(1, request);
  print('Zona creada: ${newZone.nameStudyZone}');
} on StudyZoneException catch (e) {
  if (e.statusCode == 422) {
    print('Área excedida');
  } else {
    print('Error: ${e.message}');
  }
}

// Actualizar una zona
try {
  final request = StudyZoneRequest(
    nameStudyZone: 'Zona Oeste - Actualizada',
    subArea: 200.0,
    unitId: 2,
  );
  
  final updated = await service.updateStudyZone(1, 4, request);
  print('Zona actualizada: ${updated.nameStudyZone}');
} catch (e) {
  print('Error: $e');
}

// Eliminar una zona
try {
  await service.deleteStudyZone(1, 4);
  print('Zona eliminada');
} catch (e) {
  print('Error: $e');
}
```

## Validaciones

### Nombre de zona
- No puede estar vacío
- Mínimo 3 caracteres

### Área (subArea)
- Debe ser mayor a 0
- Máximo 5000 (AREA_EXCEEDED error 422)

### UnitId
- 1: Metros
- 2: Hectáreas

## Códigos de Error

- **400**: Datos inválidos (nombre vacío, área ≤ 0)
- **404**: Recurso no encontrado (proyecto o zona)
- **422**: Área excedida (subArea > 5000)
- **500**: Error del servidor

## Widgets Visuales

### `BiodiversityChart`
Gráfico de barras para visualizar los 4 índices de biodiversidad usando fl_chart.

**Uso:**
```dart
import 'package:sylvara_frontend/features/zones/widgets/widgets.dart';
import 'package:sylvara_frontend/features/zones/models/models.dart';

// Datos de ejemplo
final indices = Indices(
  shannon: 2.45,
  simpson: 0.85,
  margalef: 3.2,
  pielou: 0.92,
);

// En el widget build:
BiodiversityChart(
  indices: indices,
  height: 250, // Opcional, default: 250
)
```

**Características:**
- ✅ 4 barras con colores verdes (#1B5E20, #2E7D32)
- ✅ Etiquetas abreviadas (S', D, d, J') en eje X
- ✅ Valores numéricos en eje Y
- ✅ Tooltips interactivos con nombre completo y valor
- ✅ Grid horizontal sutil
- ✅ Diseño responsivo con altura personalizable
- ✅ Normalización automática de valores (Simpson y Pielou × 5 para visualización)

**Nota sobre normalización:**  
Simpson y Pielou tienen valores entre 0-1, mientras Shannon y Margalef tienen valores más altos. El gráfico los normaliza multiplicando × 5 para mejor visualización, pero los tooltips muestran los valores reales.

### `BiodiversityValues`
Widget complementario que muestra los valores exactos de cada índice con descripciones.

**Uso:**
```dart
BiodiversityValues(
  indices: indices,
)
```

**Características:**
- ✅ Tarjeta (Card) con elevación
- ✅ Lista de los 4 índices con valores formateados (2 decimales)
- ✅ Descripción breve de cada índice
- ✅ Colores consistentes con BiodiversityChart

**Ejemplo de uso combinado:**
```dart
Column(
  children: [
    BiodiversityChart(indices: zone.indices),
    SizedBox(height: 16),
    BiodiversityValues(indices: zone.indices),
  ],
)
```

### `StudyZoneCard`
Tarjeta acordeón que muestra información completa de una zona de estudio con animación expandible.

**Uso básico:**
```dart
import 'package:sylvara_frontend/features/zones/widgets/widgets.dart';
import 'package:sylvara_frontend/features/zones/models/models.dart';

// En una lista de zonas
ListView.builder(
  itemCount: zones.length,
  itemBuilder: (context, index) {
    final zone = zones[index];
    return StudyZoneCard(
      zone: zone,
      onEdit: () {
        // Navegar a pantalla de edición
      },
      onViewFloraFauna: () {
        // Navegar a lista de especies
      },
      onDelete: () {
        // Mostrar confirmación y eliminar
      },
    );
  },
)
```

**Modo Comparación:**
```dart
StudyZoneCard(
  zone: zone,
  isComparing: true,  // Activa modo comparación
  isSelected: selectedZones.contains(zone.studyZoneId),
  onSelectionChanged: (selected) {
    setState(() {
      if (selected == true) {
        selectedZones.add(zone.studyZoneId);
      } else {
        selectedZones.remove(zone.studyZoneId);
      }
    });
  },
)
```

**Características:**
- ✅ Diseño basado en Figma con animaciones fluidas
- ✅ Header con icono de montaña, nombre de zona y área
- ✅ Badge de área con unidad (metros/hectáreas)
- ✅ Expansión/colapso con animación suave (300ms)
- ✅ **PopupMenu** con 3 opciones:
  - **Editar** (verde oscuro #0E3520)
  - **Flora y Fauna** (verde #4CAF50)
  - **Eliminar** (rojo #AE0000)
- ✅ **Modo comparación**: Reemplaza menú por Checkbox
- ✅ Contenido expandido muestra:
  - Valores de índices (S', D, d, J') con 2 decimales
  - BiodiversityChart integrado
- ✅ Sombra y bordes según diseño Figma
- ✅ Colores de marca: #0E3520 (principal), #F1F5F9 (fondo)

**Parámetros:**
- `zone` (requerido): StudyZone con datos completos
- `isComparing` (opcional): Activa modo comparación, default: false
- `isSelected` (opcional): Estado de selección en modo comparación, default: false
- `onEdit` (opcional): Callback al seleccionar "Editar"
- `onViewFloraFauna` (opcional): Callback al seleccionar "Flora y Fauna"
- `onDelete` (opcional): Callback al seleccionar "Eliminar"
- `onSelectionChanged` (opcional): Callback al cambiar checkbox en modo comparación
- `initiallyExpanded` (opcional): Inicia expandida, default: false

**Ejemplo completo con manejo de acciones:**
```dart
StudyZoneCard(
  zone: zone,
  initiallyExpanded: false,
  onEdit: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditZoneScreen(zoneId: zone.studyZoneId),
      ),
    );
  },
  onViewFloraFauna: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeciesListScreen(zoneId: zone.studyZoneId),
      ),
    );
  },
  onDelete: () async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar zona'),
        content: Text('¿Estás seguro de eliminar ${zone.nameStudyZone}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await StudyZoneService().deleteStudyZone(
          projectId,
          zone.studyZoneId,
        );
        // Actualizar lista
      } catch (e) {
        // Mostrar error
      }
    }
  },
)
```

## Estado Actual

✅ Modelos de datos completos con JSON mapping  
✅ Servicio con mock data para desarrollo  
✅ Manejo de errores personalizado (404, 422)  
✅ Validaciones de negocio  
✅ Widgets visuales: BiodiversityChart, BiodiversityValues, StudyZoneCard  
✅ Dependencia fl_chart agregada  
✅ Tarjeta acordeón con modo comparación y acciones  
⏳ UI completa pendiente (pantallas de lista, detalle, formularios)  
⏳ Integración con API real (reemplazar mock)  

## Datos Mock

El servicio incluye 3 zonas de ejemplo por proyecto:
1. **Zona Norte**: 250.5 ha, Shannon: 2.45, 25 especies, 150 individuos
2. **Zona Sur**: 180.0 ha, Shannon: 2.15, 20 especies, 120 individuos
3. **Zona Este**: 320.8 ha, Shannon: 2.68, 30 especies, 180 individuos

Las métricas globales se calculan automáticamente como promedio de índices y suma de contadores.
