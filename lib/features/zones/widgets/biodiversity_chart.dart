import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Widget que muestra un gráfico de barras con los índices de biodiversidad
/// 
/// Muestra 4 barras representando:
/// - Shannon (S'): Índice de diversidad de Shannon-Wiener
/// - Simpson (D): Índice de diversidad de Simpson
/// - Margalef (d): Índice de riqueza de Margalef
/// - Pielou (J'): Índice de equitatividad de Pielou
class BiodiversityChart extends StatelessWidget {
  final Indices indices;
  final double height;

  const BiodiversityChart({
    super.key,
    required this.indices,
    this.height = 250,
  });

  double get _maxY {
    final values = [indices.shannon, indices.simpson, indices.margalef, indices.pielou];
    final max = values.reduce((a, b) => a > b ? a : b);
    // Añadir un 30% de margen superior para que las barras no toquen el tope
    return (max * 1.3).clamp(1.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY;
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label;
                double realValue;
                switch (group.x.toInt()) {
                  case 0:
                    label = "Shannon (S')";
                    realValue = indices.shannon;
                    break;
                  case 1:
                    label = 'Simpson (D)';
                    realValue = indices.simpson;
                    break;
                  case 2:
                    label = 'Margalef (d)';
                    realValue = indices.margalef;
                    break;
                  case 3:
                    label = "Pielou (J')";
                    realValue = indices.pielou;
                    break;
                  default:
                    label = '';
                    realValue = 0;
                }
                return BarTooltipItem(
                  '$label\n${realValue.toStringAsFixed(3)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = "S'";
                      break;
                    case 1:
                      text = 'D';
                      break;
                    case 2:
                      text = 'd';
                      break;
                    case 3:
                      text = "J'";
                      break;
                    default:
                      text = '';
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: maxY / 5,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Color(0xFF1B5E20), width: 2),
              bottom: BorderSide(color: Color(0xFF1B5E20), width: 2),
            ),
          ),
          barGroups: _buildBarGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return [
      // Shannon (S')
      _buildBarGroup(0, indices.shannon, const Color(0xFF1B5E20)),
      // Simpson (D) - valor real sin normalización
      _buildBarGroup(1, indices.simpson, const Color(0xFF2E7D32)),
      // Margalef (d)
      _buildBarGroup(2, indices.margalef, const Color(0xFF1B5E20)),
      // Pielou (J') - valor real sin normalización
      _buildBarGroup(3, indices.pielou, const Color(0xFF2E7D32)),
    ];
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: false,
          ),
        ),
      ],
      showingTooltipIndicators: [],
    );
  }
}

/// Widget complementario que muestra los valores numéricos exactos de los índices
/// 
/// Se recomienda usar junto con [BiodiversityChart] para mostrar valores precisos
class BiodiversityValues extends StatelessWidget {
  final Indices indices;

  const BiodiversityValues({
    super.key,
    required this.indices,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Índices de Biodiversidad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            _buildIndexRow('Shannon (S\')', indices.shannon, 
              'Mide la diversidad considerando abundancia y equitatividad'),
            const Divider(height: 16),
            _buildIndexRow('Simpson (D)', indices.simpson,
              'Probabilidad de que dos individuos sean de la misma especie'),
            const Divider(height: 16),
            _buildIndexRow('Margalef (d)', indices.margalef,
              'Mide la riqueza de especies'),
            const Divider(height: 16),
            _buildIndexRow('Pielou (J\')', indices.pielou,
              'Mide la equitatividad en la distribución de especies'),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexRow(String name, double value, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
