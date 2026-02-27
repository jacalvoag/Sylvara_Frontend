# Dashboard de Proyectos - Sylvara

## Descripción
Implementación del Dashboard principal de la aplicación Sylvara. Muestra información resumida del usuario y sus proyectos más recientes.

## Contrato del Backend

### GET /dashboard

**Descripción**: Obtiene los datos del dashboard del usuario autenticado.

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Respuesta Exitosa (200)**:
```json
{
  "user": {
    "user_name": "Malaga",
    "profile_picture_url": "https://example.com/avatar.jpg" // nullable
  },
  "summary": {
    "total_historical_plots": 12,
    "current_month_plots": 3
  },
  "latest_plots": [
    {
      "id": "1",
      "name": "Predio Cuba Libre",
      "description": "Monitoreo de especies nativas",
      "status": "active",
      "image_url": "https://example.com/plot1.jpg",
      "created_at": "2026-02-15T10:30:00Z",
      "updated_at": "2026-02-26T14:20:00Z"
    }
  ]
}
```

**Respuestas de Error**:
- **401 Unauthorized**: Token inválido o expirado
- **500 Internal Server Error**: Error del servidor

## Arquitectura

### Modelos (`lib/features/projects/models/`)

#### `dashboard_response.dart`
Contiene todos los modelos para la respuesta del dashboard:

- **DashboardResponse**: Modelo principal con `user`, `summary` y `latestPlots`
- **DashboardUser**: Información del usuario (`userName`, `profilePictureUrl`)
- **DashboardSummary**: Resumen de proyectos (`totalHistoricalPlots`, `currentMonthPlots`)
- **Plot**: Proyecto individual con todos los campos del backend

**Nota**: La clase `Plot` incluye un método `toProject()` para convertir a la clase `Project` existente y mantener compatibilidad con widgets anteriores.

```dart
// Convertir Plot a Project
final project = plot.toProject();
```

#### `project_model.dart`
Modelo simple de proyecto existente (mantenido para compatibilidad):
```dart
class Project {
  final String id;
  final String nombre;
  final String descripcion;
  final bool isActive;
  final String imagen;
}
```

### Servicio (`lib/features/projects/services/`)

#### `project_service.dart`
Servicio singleton que gestiona las peticiones relacionadas con proyectos.

**Método principal**:
```dart
Future<DashboardResponse> getDashboardData()
```

**Implementación actual**:
- Mock service con datos de prueba
- Simula delay de red (1 segundo)
- Retorna `DashboardResponse` con datos hardcodeados

**Migración a backend real**:
```dart
// TODO: Reemplazar mock con HTTP real
final response = await http.get(
  Uri.parse('https://api.sylvara.com/dashboard'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);

if (response.statusCode == 200) {
  return DashboardResponse.fromJson(json.decode(response.body));
} else if (response.statusCode == 401) {
  throw DashboardException('No autenticado', statusCode: 401);
} else {
  throw DashboardException('Error del servidor', statusCode: response.statusCode);
}
```

### Pantalla (`lib/features/projects/screens/`)

#### `pantalla_inicio.dart`
Pantalla principal del dashboard con tres estados:

1. **Estado de Carga** (`_buildLoadingState`):
   - Muestra `CircularProgressIndicator`
   - Texto: "Cargando datos..."

2. **Estado de Error** (`_buildErrorState`):
   - Ícono de error
   - Mensaje de error
   - Botón "Reintentar" para recargar datos

3. **Estado Exitoso** (`_buildSuccessState`):
   - Muestra datos del dashboard
   - Dos pestañas: RESUMEN y RECIENTES

**Vista RESUMEN**:
```dart
_buildResumenView(DashboardSummary summary)
```
- SummaryCard: "Total de proyectos" → `summary.totalHistoricalPlots`
- SummaryCard: "Proyectos del mes" → `summary.currentMonthPlots`

**Vista RECIENTES**:
```dart
_buildRecientesView(List<Plot> latestPlots)
```
- ListView de ProjectCard con los últimos proyectos
- Convierte Plot a Project usando `plot.toProject()`
- Mensaje si no hay proyectos: "No hay proyectos recientes"

**Encabezado**:
```dart
CustomBienvenida(nombre: dashboard.user.userName)
```

## Flujo de Datos

```
PantallaInicio (initState)
    ↓
ProjectService.getDashboardData()
    ↓
FutureBuilder (espera respuesta)
    ↓
    ├─ ConnectionState.waiting → _buildLoadingState()
    ├─ snapshot.hasError → _buildErrorState()
    └─ snapshot.hasData → _buildSuccessState(dashboard)
        ↓
        ├─ Tab RESUMEN → _buildResumenView(dashboard.summary)
        └─ Tab RECIENTES → _buildRecientesView(dashboard.latestPlots)
```

## Uso

### Iniciar la pantalla

```dart
import 'package:sylvara_frontend/features/projects/screens/pantalla_inicio.dart';

// En main.dart o router
MaterialApp(
  home: const PantallaInicio(),
)
```

### Recargar datos manualmente

El botón "Reintentar" en el estado de error recarga los datos:
```dart
setState(() {
  _dashboardFuture = _projectService.getDashboardData();
});
```

## Widgets Utilizados

### Core Widgets (`lib/core/widgets/`)
- `BackgroundImage`: Fondo de la pantalla (FondoHome.png)
- `CustomBienvenida`: Encabezado con nombre del usuario
- `SummaryCard`: Tarjeta de resumen con título y valor numérico
- `ProjectCard`: Tarjeta de proyecto con imagen, nombre y descripción
- `MenuNavegation`: Menú de navegación inferior

## Datos Mock

Actualmente, `ProjectService.getDashboardData()` retorna:

```dart
{
  "user": {
    "user_name": "Malaga",
    "profile_picture_url": null
  },
  "summary": {
    "total_historical_plots": 12,
    "current_month_plots": 3
  },
  "latest_plots": [
    {
      "id": "1",
      "name": "Predio Cuba Libre",
      "description": "Monitoreo de especies nativas en zona protegida",
      "status": "active",
      "image_url": "https://via.placeholder.com/48",
      "created_at": "2026-02-15T10:30:00Z",
      "updated_at": "2026-02-26T14:20:00Z"
    },
    {
      "id": "2",
      "name": "Reserva Natural del Noreste",
      "description": "Estudio de biodiversidad y conservación",
      "status": "active",
      "image_url": "https://via.placeholder.com/48",
      "created_at": "2026-02-10T08:15:00Z",
      "updated_at": "2026-02-25T16:45:00Z"
    },
    {
      "id": "3",
      "name": "Parque Nacional Sierra Verde",
      "description": "Investigación forestal y fauna silvestre",
      "status": "inactive",
      "image_url": "https://via.placeholder.com/48",
      "created_at": "2026-01-20T12:00:00Z",
      "updated_at": "2026-02-20T09:30:00Z"
    }
  ]
}
```

## Testing

### Verificar estados del FutureBuilder

1. **Estado de carga**: Aparece por 1 segundo mientras carga datos mock
2. **Estado exitoso**: Muestra dashboard con datos de Malaga
3. **Estado de error**: Forzar error modificando el servicio:
   ```dart
   Future<DashboardResponse> getDashboardData() async {
     await Future.delayed(const Duration(seconds: 1));
     throw Exception('Error simulado');
   }
   ```

### Verificar datos en consola

Al cargar el dashboard, aparecen logs:
```
📊 Dashboard data obtenido exitosamente
👤 Usuario: Malaga
📈 Total proyectos: 12
📅 Proyectos del mes: 3
🗂️ Proyectos recientes: 3
```

## Próximos Pasos

### 1. Migrar a backend real
- [ ] Agregar dependencia `http` en `pubspec.yaml`
- [ ] Implementar `AuthService.getAccessToken()`
- [ ] Crear `DashboardException` similar a `AuthException`
- [ ] Actualizar `getDashboardData()` con HTTP call
- [ ] Manejar tokens expirados (401 → logout)

### 2. Agregar caché
- [ ] Guardar dashboard en SharedPreferences
- [ ] Mostrar caché mientras carga datos frescos
- [ ] Implementar pull-to-refresh

### 3. Navegación
- [ ] Implementar detalle de proyecto al tocar ProjectCard
- [ ] Navegar a perfil al tocar CustomBienvenida
- [ ] Implementar MenuNavegation completo

### 4. Imagen de perfil
- [ ] Mostrar avatar si `profilePictureUrl` no es null
- [ ] Agregar fallback con iniciales del nombre

## Estructura de Archivos

```
lib/features/projects/
├── models/
│   ├── dashboard_response.dart    # Modelos del dashboard
│   ├── project_model.dart          # Modelo simple de proyecto
│   └── models.dart                 # Barrel file
├── services/
│   └── project_service.dart        # Servicio de proyectos
├── screens/
│   └── pantalla_inicio.dart        # Pantalla principal del dashboard
└── README.md                       # Esta documentación
```

## Dependencias

- `flutter/material.dart`: Framework base
- `core/widgets/widgets.dart`: Widgets reutilizables
- `projects/models/models.dart`: Modelos de datos
- `projects/services/project_service.dart`: Lógica de negocio

## Notas Importantes

1. **Compatibilidad**: El método `Plot.toProject()` convierte el modelo del backend al modelo de UI existente, permitiendo usar widgets creados previamente sin modificaciones.

2. **Estados**: El FutureBuilder maneja todos los estados de la carga asíncrona automáticamente. No se necesita manejo manual de loading/error.

3. **Singleton**: ProjectService usa el patrón singleton para mantener una única instancia y facilitar acceso global.

4. **Field Names**: Todos los nombres de campos JSON coinciden exactamente con el contrato del backend (snake_case en JSON, camelCase en Dart).

5. **Reintentar**: El botón "Reintentar" crea un nuevo Future, lo que fuerza a FutureBuilder a reconstruirse y volver a cargar los datos.
