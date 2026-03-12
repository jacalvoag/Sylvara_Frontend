import 'package:flutter/material.dart';
import '../services/export_service.dart';

class ExportButton extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ExportButton({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _loading = false;

  Future<void> _handleExport() async {
    setState(() => _loading = true);
    try {
      final service = ExportService();

      // 1. Fetch data from backend
      final report = await service.getReportData(widget.projectId);

      // 2. Build PDF bytes
      final pdfBytes = await service.buildPdf(report);

      // 3. Share / Save (nativo en iOS & Android, descarga en Web)
      if (!mounted) return;
      final fileName =
          'sylvara_${widget.projectName.toLowerCase().replaceAll(' ', '_')}_ciclo${report.cycleNumber}.pdf';
      await service.shareOrSavePdf(context, pdfBytes, fileName);
    } on ExportException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Ocurrió un error al generar el reporte.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          )
        : IconButton.filled(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar reporte PDF',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF0E3520),
              foregroundColor: Colors.white,
            ),
            onPressed: _handleExport,
          );
  }
}