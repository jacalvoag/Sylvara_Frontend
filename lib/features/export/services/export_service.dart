// lib/features/export/services/export_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../models/report_data_model.dart';

class ExportException implements Exception {
  final String message;
  final int statusCode;
  ExportException({required this.message, this.statusCode = 500});
  @override
  String toString() => 'ExportException($statusCode): $message';
}

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final _apiClient = ApiClient();

  // ── 1. Fetch report data from backend ─────────────────────────────────

  Future<ReportDataModel> getReportData(int projectId) async {
    final response = await _apiClient.get(
      '${ApiConfig.baseUrl}/export/report-data/$projectId',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ReportDataModel.fromJson(data as Map<String, dynamic>);
    }

    throw ExportException(
      message: data['message'] as String? ?? 'Error al obtener datos del reporte',
      statusCode: response.statusCode,
    );
  }

  // ── 2. Build PDF bytes from ReportDataModel ────────────────────────────

  Future<Uint8List> buildPdf(ReportDataModel report) async {
    final pdf = pw.Document();

    // Colors
    const darkGreen = PdfColor.fromInt(0xFF0E3520);
    const lightGreen = PdfColor.fromInt(0xFF4CAF50);
    const bgGray = PdfColor.fromInt(0xFFF1F5F9);
    const textGray = PdfColor.fromInt(0xFF666666);
    const white = PdfColors.white;

    final dateFormatter = DateFormat('dd/MM/yyyy');
    String fmt(DateTime? d) => d != null ? dateFormatter.format(d) : '—';

    // ── PAGE 1: Portada + métricas globales ────────────────────────────
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => [
          // Header verde
          pw.Container(
            width: double.infinity,
            color: darkGreen,
            padding: const pw.EdgeInsets.fromLTRB(32, 36, 32, 28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SYLVARA',
                  style: pw.TextStyle(
                    color: white,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  report.projectName,
                  style: pw.TextStyle(
                    color: white,
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (report.description != null && report.description!.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6),
                    child: pw.Text(
                      report.description!,
                      style: pw.TextStyle(color: const PdfColor(1, 1, 1, 0.7), fontSize: 12),
                    ),
                  ),
                pw.SizedBox(height: 20),
                // Fila de badges
                pw.Row(children: [
                  _badge(report.isActive ? 'Activo' : 'Inactivo', lightGreen, white),
                  pw.SizedBox(width: 8),
                  _badge('Ciclo ${report.cycleNumber}', white, darkGreen),
                  pw.SizedBox(width: 8),
                  _badge('${report.totalArea.toStringAsFixed(1)} ${report.unitName}', white, darkGreen),
                ]),
              ],
            ),
          ),

          // Cuerpo con padding
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Información general
                _sectionTitle('Información General', darkGreen),
                pw.SizedBox(height: 12),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: bgGray,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(children: [
                    _infoRow('Investigador', report.researcherFullName, textGray),
                    _infoRow('Inicio', fmt(report.startDate), textGray),
                    _infoRow('Cierre', report.endDate != null ? fmt(report.endDate) : '', textGray),
                    _infoRow('Área total', '${report.totalArea.toStringAsFixed(2)} ${report.unitName}', textGray),
                    _infoRow('Número de zonas', '${report.zonesDetails.length}', textGray),
                    _infoRow('Estado', report.isActive ? 'Activo' : 'Inactivo', textGray),
                  ]),
                ),

                pw.SizedBox(height: 24),

                // Métricas globales
                _sectionTitle('Índices Globales de Biodiversidad', darkGreen),
                pw.SizedBox(height: 12),
                _indicesGrid(report.globalMetrics.indices, darkGreen, bgGray),

                pw.SizedBox(height: 16),
                // Riqueza y abundancia
                pw.Row(children: [
                  pw.Expanded(
                    child: _metricCard(
                      'Riqueza de especies',
                      '${report.globalMetrics.speciesRichness}',
                      darkGreen, bgGray,
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _metricCard(
                      'Total de individuos',
                      '${report.globalMetrics.totalIndividuals}',
                      darkGreen, bgGray,
                    ),
                  ),
                ]),

                pw.SizedBox(height: 24),

                // Resumen de zonas
                _sectionTitle('Zonas de Estudio (${report.zonesDetails.length})', darkGreen),
                pw.SizedBox(height: 12),
                ...report.zonesDetails.map((zone) => _zoneSummaryRow(zone, darkGreen, bgGray, textGray)),
              ],
            ),
          ),
        ],
      ),
    );

    // ── PÁGINAS ADICIONALES: Una por zona con tabla de especies ──────────
    for (final zone in report.zonesDetails) {
      if (zone.speciesRecords.isEmpty) continue;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
          header: (context) => pw.Container(
            color: darkGreen,
            padding: const pw.EdgeInsets.fromLTRB(32, 18, 32, 18),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  zone.zoneName,
                  style: pw.TextStyle(
                    color: white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '${report.projectName} · Ciclo ${zone.cycleNumber}',
                  style: pw.TextStyle(color: const PdfColor(1, 1, 1, 0.7), fontSize: 10),
                ),
              ],
            ),
          ),
          build: (context) => [
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(32, 20, 32, 0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Sub-área y métricas de la zona
                  pw.Row(children: [
                    _badge('${zone.subArea.toStringAsFixed(1)} ${zone.unitName}', bgGray, darkGreen),
                    pw.SizedBox(width: 8),
                    _badge('Especies registradas: ${zone.speciesRichness}', bgGray, darkGreen),
                    pw.SizedBox(width: 8),
                    _badge('Total de individuos: ${zone.totalIndividuals} ', bgGray, darkGreen),
                  ]),
                  pw.SizedBox(height: 16),

                  // Índices de la zona
                  _sectionTitle('Índices de biodiversidad', darkGreen),
                  pw.SizedBox(height: 10),
                  _indicesGrid(zone.indices, darkGreen, bgGray),
                  pw.SizedBox(height: 20),

                  // Tabla de especies
                  _sectionTitle('Registro de especies', darkGreen),
                  pw.SizedBox(height: 10),
                  _speciesTable(zone.speciesRecords, darkGreen, bgGray, white, textGray),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return pdf.save();
  }

  // ── 3. Share/Save ──────────────────────────────────────────────────────

  /// Abre el dialogo nativo de compartir/guardar (funciona en iOS, Android y Web)
  Future<void> shareOrSavePdf(
    BuildContext context,
    Uint8List pdfBytes,
    String fileName,
  ) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  // ── Widget helpers ─────────────────────────────────────────────────────

  pw.Widget _badge(String text, PdfColor bg, PdfColor fg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: fg, fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _sectionTitle(String text, PdfColor color) {
    return pw.Row(children: [
      pw.Container(width: 4, height: 18, color: color),
      pw.SizedBox(width: 8),
      pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    ]);
  }

  pw.Widget _infoRow(String label, String value, PdfColor textGray) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 11, color: textGray)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _indicesGrid(ReportIndices indices, PdfColor dark, PdfColor bg) {
    return pw.Row(children: [
      pw.Expanded(child: _indexBox("Shannon (S')", indices.shannon.toStringAsFixed(3), dark, bg)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _indexBox('Simpson (D)', indices.simpson.toStringAsFixed(3), dark, bg)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _indexBox('Margalef (d)', indices.margalef.toStringAsFixed(3), dark, bg)),
      pw.SizedBox(width: 8),
      pw.Expanded(child: _indexBox("Pielou (J')", indices.pielou.toStringAsFixed(3), dark, bg)),
    ]);
  }

  pw.Widget _indexBox(String label, String value, PdfColor dark, PdfColor bg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: dark, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: dark,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  pw.Widget _metricCard(String label, String value, PdfColor dark, PdfColor bg) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: dark, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: dark,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _zoneSummaryRow(
    ZoneBiodiversityReport zone,
    PdfColor dark,
    PdfColor bg,
    PdfColor textGray,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: dark, width: 0.5),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              zone.zoneName,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'Especies registradas: ${zone.speciesRichness}',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'Total de individuos: ${zone.totalIndividuals}',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              "S'=${zone.indices.shannon.toStringAsFixed(2)}",
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _speciesTable(
    List<SpeciesRecordReport> records,
    PdfColor dark,
    PdfColor bg,
    PdfColor white,
    PdfColor textGray,
  ) {
    const headers = ['Especie', 'Tipo funcional', 'Individuos', 'Estrato (min-max)'];

    return pw.Table(
      border: pw.TableBorder.all(color: dark, width: 0.4),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Cabecera
        pw.TableRow(
          decoration: pw.BoxDecoration(color: dark),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                      color: white,
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        // Filas de datos
        ...records.asMap().entries.map((entry) {
          final i = entry.key;
          final sr = entry.value;
          final rowColor = i.isOdd ? bg : PdfColors.white;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: rowColor),
            children: [
              _tableCell(sr.speciesName, textGray),
              _tableCell(sr.functionalTypeName, textGray),
              _tableCell('${sr.individualCount}', textGray, center: true),
              _tableCell(
                sr.heightMin == 0 && sr.heightMax == 0
                    ? '—'
                    : '${sr.heightMin.toStringAsFixed(1)} - ${sr.heightMax.toStringAsFixed(1)} ${sr.unitName}',
                textGray,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableCell(String text, PdfColor color, {bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: 9, color: color),
      ),
    );
  }
}