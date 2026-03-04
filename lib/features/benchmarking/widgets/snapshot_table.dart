import 'package:flutter/material.dart';
import 'package:sylvara_frontend/features/benchmarking/models/models.dart';

class SnapshotTable extends StatefulWidget {
  final List<SnapshotRow> rows;

  const SnapshotTable({super.key, required this.rows});

  @override
  State<SnapshotTable> createState() => _SnapshotTableState();
}

class _SnapshotTableState extends State<SnapshotTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = false;
  late List<SnapshotRow> _sortedRows;

  @override
  void initState() {
    super.initState();
    _sortedRows = List.from(widget.rows);
    _sortByColumn(2, false); // Default: sort by mean time desc
  }

  @override
  void didUpdateWidget(covariant SnapshotTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows) {
      _sortedRows = List.from(widget.rows);
      _sortByColumn(_sortColumnIndex, _sortAscending);
    }
  }

  void _sortByColumn(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedRows.sort((a, b) {
        int result;
        switch (columnIndex) {
          case 0:
            result = a.query.compareTo(b.query);
            break;
          case 1:
            result = a.calls.compareTo(b.calls);
            break;
          case 2:
            result = a.meanExecTimeMs.compareTo(b.meanExecTimeMs);
            break;
          case 3:
            result = a.totalExecTimeMs.compareTo(b.totalExecTimeMs);
            break;
          case 4:
            result = a.rowsReturned.compareTo(b.rowsReturned);
            break;
          case 5:
            result = a.sharedBlksHit.compareTo(b.sharedBlksHit);
            break;
          default:
            result = 0;
        }
        return ascending ? result : -result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 48,
              color: const Color(0xFF0E3520).withOpacity(0.2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sin datos en el snapshot',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E3520).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_sortedRows.length} queries',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0E3520),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Desliza para ver más columnas',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: const Color(0xFF0E3520).withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.swipe_rounded,
                  size: 14,
                  color: const Color(0xFF0E3520).withOpacity(0.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Table
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                headingRowHeight: 44,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 52,
                columnSpacing: 20,
                horizontalMargin: 20,
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFB)),
                dataRowColor: WidgetStateProperty.resolveWith<Color>((states) {
                  return Colors.white;
                }),
                headingTextStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E3520),
                  letterSpacing: 0.5,
                ),
                dataTextStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
                columns: [
                  DataColumn(
                    label: const Text('QUERY'),
                    onSort: (i, asc) => _sortByColumn(i, asc),
                  ),
                  DataColumn(
                    label: const Text('CALLS'),
                    numeric: true,
                    onSort: (i, asc) => _sortByColumn(i, asc),
                  ),
                  DataColumn(
                    label: const Text('AVG (ms)'),
                    numeric: true,
                    onSort: (i, asc) => _sortByColumn(i, asc),
                  ),
                  DataColumn(
                    label: const Text('TOTAL (ms)'),
                    numeric: true,
                    onSort: (i, asc) => _sortByColumn(i, asc),
                  ),
                  DataColumn(
                    label: const Text('ROWS'),
                    numeric: true,
                    onSort: (i, asc) => _sortByColumn(i, asc),
                  ),
                  DataColumn(
                    label: const Text('BLK HIT'),
                    numeric: true,
                    onSort: (i, asc) => _sortByColumn(i, asc),
                  ),
                ],
                rows: _sortedRows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  final isEven = index % 2 == 0;

                  return DataRow(
                    color: WidgetStateProperty.all(
                      isEven ? Colors.white : const Color(0xFFFAFCFB),
                    ),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Tooltip(
                            message: row.query,
                            child: Text(
                              row.queryShort,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(_buildNumericCell('${row.calls}')),
                      DataCell(_buildNumericCell(
                        row.meanExecTimeMs.toStringAsFixed(3),
                        highlight: row.meanExecTimeMs > 1.0,
                      )),
                      DataCell(_buildNumericCell(
                        row.totalExecTimeMs.toStringAsFixed(2),
                      )),
                      DataCell(_buildNumericCell('${row.rowsReturned}')),
                      DataCell(_buildNumericCell('${row.sharedBlksHit}')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericCell(String value, {bool highlight = false}) {
    return Text(
      value,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 11,
        fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
        color: highlight ? const Color(0xFFDC2626) : const Color(0xFF334155),
      ),
    );
  }
}