import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:sylvara_frontend/core/api/token_storage.dart';
import 'package:sylvara_frontend/features/benchmarking/models/models.dart';
import 'package:sylvara_frontend/features/benchmarking/service/benchmarking_service.dart';
import 'package:sylvara_frontend/features/benchmarking/widgets/widgets.dart';

class BenchmarkingScreen extends StatefulWidget {
  const BenchmarkingScreen({super.key});

  @override
  State<BenchmarkingScreen> createState() => _BenchmarkingScreenState();
}

class _BenchmarkingScreenState extends State<BenchmarkingScreen>
    with SingleTickerProviderStateMixin {
  final _service = BenchmarkingService();
  final _tokenStorage = TokenStorage();

  bool _googleConnected = false;
  bool _isLoadingGoogle = false;
  bool _isProcessing = false;
  bool _isError = false;
  int _currentStep = 0;
  String? _statusMessage;
  List<SnapshotRow> _snapshotRows = [];
  bool _showSnapshot = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _checkGoogleStatus();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3520).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.open_in_new_rounded,
                  color: Color(0xFF0E3520),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Autorización en progreso',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E3520),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completa la autorización con Google en la pestaña que se abrió y luego regresa aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: const Color(0xFF0E3520).withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _checkGoogleStatus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E3520),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ya autoricé, verificar',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _handleSnapshot() async {
    setState(() {
      _isProcessing = true;
      _isError = false;
      _statusMessage = 'Consultando pg_stat_statements...';
    });

    try {
      final rows = await _service.getSnapshot();
      setState(() {
        _snapshotRows = rows;
        _showSnapshot = true;
        _currentStep = 1;
        _statusMessage = '${rows.length} queries capturadas en el snapshot';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al obtener snapshot';
        _isProcessing = false;
        _isError = true;
      });
    }
  }

  Future<void> _handleCsvBackup() async {
    setState(() {
      _isProcessing = true;
      _isError = false;
      _statusMessage = 'Generando CSV de respaldo...';
    });

    try {
      final result = await _service.generateCsv();
      setState(() {
        _currentStep = 2;
        _statusMessage = 'CSV generado: ${result['filename'] ?? 'respaldo listo'}';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al generar CSV';
        _isProcessing = false;
        _isError = true;
      });
    }
  }

  Future<void> _handleSendBigQuery() async {
    setState(() {
      _isProcessing = true;
      _isError = false;
      _statusMessage = 'Enviando métricas a BigQuery...';
    });

    try {
      final result = await _service.sendToBigQuery();
      setState(() {
        _currentStep = 3;
        _statusMessage = '${result['rowsInserted'] ?? 0} filas enviadas a BigQuery';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al enviar a BigQuery';
        _isProcessing = false;
        _isError = true;
      });
    }
  }

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Resetear estadísticas?',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E3520),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Se limpiarán los datos de pg_stat_statements. Solo hazlo después de un envío exitoso.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: const Color(0xFF0E3520).withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Resetear',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
      _isError = false;
      _statusMessage = 'Reseteando pg_stat_statements...';
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
        _statusMessage = 'Error al resetear estadísticas';
        _isProcessing = false;
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: const Color(0xFF0E3520),
                      iconSize: 24,
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Benchmarking',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0E3520),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Panel de rendimiento PostgreSQL',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0E3520).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Refresh button
                    GestureDetector(
                      onTap: _checkGoogleStatus,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFF0E3520),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Google status
                      GoogleStatusCard(
                        isConnected: _googleConnected,
                        isLoading: _isLoadingGoogle,
                        onConnect: _connectGoogle,
                      ),

                      const SizedBox(height: 20),

                      // Corte del dia
                      CortDelDiaCard(
                        googleConnected: _googleConnected,
                        currentStep: _currentStep,
                        isProcessing: _isProcessing,
                        statusMessage: _statusMessage,
                        isError: _isError,
                        onSnapshot: _handleSnapshot,
                        onCsvBackup: _handleCsvBackup,
                        onSendBigQuery: _handleSendBigQuery,
                        onReset: _handleReset,
                      ),

                      // Snapshot table
                      if (_showSnapshot) ...[
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0E3520),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Snapshot actual',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0E3520),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SnapshotTable(rows: _snapshotRows),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
