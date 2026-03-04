import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:sylvara_frontend/core/api/token_storage.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/benchmarking/models/models.dart';
import 'package:sylvara_frontend/features/benchmarking/service/benchmarking_service.dart';
import 'package:sylvara_frontend/features/benchmarking/widgets/widgets.dart';

class BenchmarkingScreen extends StatefulWidget {
  const BenchmarkingScreen({super.key});

  @override
  State<BenchmarkingScreen> createState() => _BenchmarkingScreenState();
}

class _BenchmarkingScreenState extends State<BenchmarkingScreen> {
  final _service = BenchmarkingService();
  final _tokenStorage = TokenStorage();

  bool _googleConnected = false;
  bool _isLoadingGoogle = false;
  bool _isProcessing = false;
  int _currentStep = 0;
  String? _statusMessage;
  List<SnapshotRow> _snapshotRows = [];
  bool _showSnapshot = false;

  @override
  void initState() {
    super.initState();
    _checkGoogleStatus();
  }

  Future<void> _checkGoogleStatus() async {
    setState(() => _isLoadingGoogle = true);
    try {
      final connected = await _service.isGoogleConnected();
      setState(() => _googleConnected = connected);
    } catch (e) {
      setState(() => _googleConnected = false);
    } finally {
      setState(() => _isLoadingGoogle = false);
    }
  }

  Future<void> _connectGoogle() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return;

    final url = _service.getGoogleAuthUrl(token);
    html.window.open(url, '_blank');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Completa la autorización en la pestaña de Google, luego vuelve aquí'),
          backgroundColor: const Color(0xFF0E3520),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Verificar',
            textColor: Colors.white,
            onPressed: _checkGoogleStatus,
          ),
        ),
      );
    }
  }

  Future<void> _handleSnapshot() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Obteniendo snapshot...';
    });

    try {
      final rows = await _service.getSnapshot();
      setState(() {
        _snapshotRows = rows;
        _showSnapshot = true;
        _currentStep = 1;
        _statusMessage = '${rows.length} filas en el snapshot';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleCsvBackup() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Generando CSV de respaldo...';
    });

    try {
      final result = await _service.generateCsv();
      setState(() {
        _currentStep = 2;
        _statusMessage = 'CSV generado: ${result['filename'] ?? 'OK'}';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al generar CSV: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleSendBigQuery() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Enviando a BigQuery...';
    });

    try {
      final result = await _service.sendToBigQuery();
      setState(() {
        _currentStep = 3;
        _statusMessage = 'Enviado: ${result['rowsInserted'] ?? 0} filas a BigQuery';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al enviar: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Resetear estadísticas?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E3520),
          ),
        ),
        content: const Text(
          'Esto limpiará pg_stat_statements. Solo hazlo después de un envío exitoso a BigQuery.',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E3520)),
            child: const Text('Resetear', style: TextStyle(fontFamily: 'Montserrat', color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Reseteando estadísticas...';
    });

    try {
      await _service.resetStatistics();
      setState(() {
        _currentStep = 4;
        _statusMessage = 'Corte del día completado exitosamente';
        _isProcessing = false;
        _snapshotRows = [];
        _showSnapshot = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al resetear: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/FondoHome.png',
            height: 610,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF0E3520), size: 28),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Bench',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                            TextSpan(
                              text: 'marking',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          GoogleStatusCard(
                            isConnected: _googleConnected,
                            isLoading: _isLoadingGoogle,
                            onConnect: _connectGoogle,
                          ),
                          const SizedBox(height: 20),
                          CortDelDiaCard(
                            googleConnected: _googleConnected,
                            currentStep: _currentStep,
                            isProcessing: _isProcessing,
                            statusMessage: _statusMessage,
                            onSnapshot: _handleSnapshot,
                            onCsvBackup: _handleCsvBackup,
                            onSendBigQuery: _handleSendBigQuery,
                            onReset: _handleReset,
                          ),
                          if (_showSnapshot) ...[
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Snapshot actual',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0E3520),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 400,
                              child: SingleChildScrollView(
                                child: SnapshotTable(rows: _snapshotRows),
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}