class SnapshotRow {
  final int projectId;
  final String snapshotDate;
  final String queryid;
  final int dbid;
  final int userid;
  final String query;
  final int calls;
  final double totalExecTimeMs;
  final double meanExecTimeMs;
  final double minExecTimeMs;
  final double maxExecTimeMs;
  final double stddevExecTimeMs;
  final int rowsReturned;
  final int sharedBlksHit;
  final int sharedBlksRead;

  SnapshotRow({
    required this.projectId,
    required this.snapshotDate,
    required this.queryid,
    required this.dbid,
    required this.userid,
    required this.query,
    required this.calls,
    required this.totalExecTimeMs,
    required this.meanExecTimeMs,
    required this.minExecTimeMs,
    required this.maxExecTimeMs,
    required this.stddevExecTimeMs,
    required this.rowsReturned,
    required this.sharedBlksHit,
    required this.sharedBlksRead,
  });

  factory SnapshotRow.fromJson(Map<String, dynamic> json) {
    return SnapshotRow(
      projectId: _toInt(json['project_id']),
      snapshotDate: json['snapshot_date']?.toString() ?? '',
      queryid: json['queryid']?.toString() ?? '',
      dbid: _toInt(json['dbid']),
      userid: _toInt(json['userid']),
      query: json['query']?.toString() ?? '',
      calls: _toInt(json['calls']),
      totalExecTimeMs: _toDouble(json['total_exec_time_ms']),
      meanExecTimeMs: _toDouble(json['mean_exec_time_ms']),
      minExecTimeMs: _toDouble(json['min_exec_time_ms']),
      maxExecTimeMs: _toDouble(json['max_exec_time_ms']),
      stddevExecTimeMs: _toDouble(json['stddev_exec_time_ms']),
      rowsReturned: _toInt(json['rows_returned']),
      sharedBlksHit: _toInt(json['shared_blks_hit']),
      sharedBlksRead: _toInt(json['shared_blks_read']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get queryShort {
    if (query.length <= 60) return query;
    return '${query.substring(0, 57)}...';
  }
}