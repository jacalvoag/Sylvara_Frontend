import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

/// Ejemplo de pantalla que muestra cómo usar BiodiversityChart y BiodiversityValues
/// 
/// Este es un ejemplo de referencia. Puedes integrar estos widgets en tus propias pantallas.
class BiodiversityChartExampleScreen extends StatelessWidget {
  const BiodiversityChartExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo (normalmente vendrían de StudyZoneService)
    final exampleIndices = Indices(
      shannon: 2.45,   // Rango típico: 0-5
      simpson: 0.85,   // Rango: 0-1
      margalef: 3.2,   // Rango: 0+
      pielou: 0.92,    // Rango: 0-1
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Índices de Biodiversidad'),
        backgroundColor: const Color(0xFF0E3520),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            const Text(
              'Gráfica de Biodiversidad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E3520),
              ),
            ),
            const SizedBox(height: 16),
            
            // Widget principal: Gráfico de barras
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BiodiversityChart(
                  indices: exampleIndices,
                  height: 280,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Widget complementario: Valores con descripciones
            BiodiversityValues(indices: exampleIndices),
            
            const SizedBox(height: 24),
            
            // Información adicional
            Card(
              color: const Color(0xFFE8F5E9),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF1B5E20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nota sobre visualización',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Los valores de Simpson y Pielou se multiplican por 5 para mejorar '
                      'la visualización en el gráfico, pero las etiquetas de herramientas '
                      'muestran los valores reales.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ejemplo de integración con datos reales
            const Text(
              'Integración con datos reales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0E3520),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Para usar con datos de StudyZoneService:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'final response = await StudyZoneService()\n'
                        '    .getProjectZones(projectId);\n\n'
                        'BiodiversityChart(\n'
                        '  indices: response.globalMetrics.indices,\n'
                        ')\n\n'
                        '// O para una zona específica:\n'
                        'BiodiversityChart(\n'
                        '  indices: zone.indices,\n'
                        ')',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
