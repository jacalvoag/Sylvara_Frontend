import 'package:flutter/material.dart';

class CortDelDiaCard extends StatelessWidget {
  final bool googleConnected;
  final int currentStep;
  final bool isProcessing;
  final String? statusMessage;
  final VoidCallback onSnapshot;
  final VoidCallback onCsvBackup;
  final VoidCallback onSendBigQuery;
  final VoidCallback onReset;

  const CortDelDiaCard({
    super.key,
    required this.googleConnected,
    required this.currentStep,
    required this.isProcessing,
    this.statusMessage,
    required this.onSnapshot,
    required this.onCsvBackup,
    required this.onSendBigQuery,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0E3520),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Corte del Día',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E3520),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Exportar métricas de rendimiento a BigQuery',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: const Color(0xFF0E3520).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          _buildStep(1, 'Ver Snapshot', Icons.visibility, onSnapshot, currentStep >= 0),
          const SizedBox(height: 10),
          _buildStep(2, 'Generar CSV de respaldo', Icons.file_download, onCsvBackup, currentStep >= 1),
          const SizedBox(height: 10),
          _buildStep(3, 'Enviar a BigQuery', Icons.cloud_upload, onSendBigQuery, currentStep >= 2 && googleConnected),
          const SizedBox(height: 10),
          _buildStep(4, 'Resetear estadísticas', Icons.restart_alt, onReset, currentStep >= 3),
          if (statusMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0E3520).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF0E3520).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  if (isProcessing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0E3520),
                      ),
                    )
                  else
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF0E3520)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      statusMessage!,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0E3520),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, IconData icon, VoidCallback onTap, bool enabled) {
    final bool isCompleted = currentStep >= step;
    final bool isCurrent = currentStep == step - 1;

    return GestureDetector(
      onTap: enabled && !isProcessing ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF0E3520).withOpacity(0.08)
              : enabled
                  ? Colors.white
                  : const Color(0xFFE0E0E0).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? const Color(0xFF0E3520)
                : isCompleted
                    ? const Color(0xFF0E3520).withOpacity(0.3)
                    : const Color(0xFFE0E0E0),
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF0E3520)
                    : enabled
                        ? const Color(0xFF0E3520).withOpacity(0.1)
                        : const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$step',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: enabled ? const Color(0xFF0E3520) : const Color(0xFF757575),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 20, color: enabled ? const Color(0xFF0E3520) : const Color(0xFF757575)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled ? const Color(0xFF0E3520) : const Color(0xFF757575),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}