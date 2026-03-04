import 'package:flutter/material.dart';
import 'package:sylvara_frontend/features/benchmarking/models/models.dart';

class SnapshotTable extends StatelessWidget {
  final List<SnapshotRow> rows;

  const SnapshotTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos en el snapshot',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFF0E3520).withOpacity(0.05),
          ),
          columnSpacing: 16,
          horizontalMargin: 12,
          headingTextStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0E3520),
          ),
          dataTextStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 10,
            color: Color(0xFF0E3520),
          ),
          columns: const [
            DataColumn(label: Text('Query')),
            DataColumn(label: Text('Calls'), numeric: true),
            DataColumn(label: Text('Mean (ms)'), numeric: true),
            DataColumn(label: Text('Total (ms)'), numeric: true),
            DataColumn(label: Text('Rows'), numeric: true),
            DataColumn(label: Text('Blks Hit'), numeric: true),
            DataColumn(label: Text('Blks Read'), numeric: true),
          ],
          rows: rows.map((row) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(row.queryShort, overflow: TextOverflow.ellipsis),
                ),
              ),
              DataCell(Text('${row.calls}')),
              DataCell(Text(row.meanExecTimeMs.toStringAsFixed(2))),
              DataCell(Text(row.totalExecTimeMs.toStringAsFixed(2))),
              DataCell(Text('${row.rowsReturned}')),
              DataCell(Text('${row.sharedBlksHit}')),
              DataCell(Text('${row.sharedBlksRead}')),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}