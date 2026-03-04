import 'package:flutter/material.dart';

class CortDelDiaCard extends StatelessWidget {
  final bool googleConnected;
  final int currentStep;
  final bool isProcessing;
  final String? statusMessage;
  final bool? isError;
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
    this.isError,
    required this.onSnapshot,
    required this.onCsvBackup,
    required this.onSendBigQuery,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComplete = currentStep >= 4;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            decoration: BoxDecoration(
              gradient: isComplete
                  ? const LinearGradient(
                      colors: [Color(0xFF0E3520), Color(0xFF1A5C38)],
                    )
                  : null,
              color: isComplete ? null : const Color(0xFFFAFCFB),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFF0E3520).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isComplete ? Icons.verified_rounded : Icons.analytics_outlined,
                    color: isComplete ? Colors.white : const Color(0xFF0E3520),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isComplete ? 'Corte completado' : 'Corte del Día',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isComplete ? Colors.white : const Color(0xFF0E3520),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isComplete
                            ? 'Métricas exportadas exitosamente'
                            : 'Exportar métricas a BigQuery',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isComplete
                              ? Colors.white.withOpacity(0.75)
                              : const Color(0xFF0E3520).withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress indicator
                if (!isComplete)
                  _buildProgressRing(),
              ],
            ),
          ),

          // Steps
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              children: [
                _StepTile(
                  step: 1,
                  label: 'Ver Snapshot',
                  subtitle: 'Consultar pg_stat_statements',
                  icon: Icons.visibility_rounded,
                  isCompleted: currentStep >= 1,
                  isCurrent: currentStep == 0,
                  isEnabled: true,
                  isProcessing: isProcessing && currentStep == 0,
                  onTap: isProcessing ? null : onSnapshot,
                ),
                _StepConnector(isActive: currentStep >= 1),
                _StepTile(
                  step: 2,
                  label: 'Respaldo CSV',
                  subtitle: 'Generar archivo de respaldo',
                  icon: Icons.file_download_outlined,
                  isCompleted: currentStep >= 2,
                  isCurrent: currentStep == 1,
                  isEnabled: currentStep >= 1,
                  isProcessing: isProcessing && currentStep == 1,
                  onTap: currentStep >= 1 && !isProcessing ? onCsvBackup : null,
                ),
                _StepConnector(isActive: currentStep >= 2),
                _StepTile(
                  step: 3,
                  label: 'Enviar a BigQuery',
                  subtitle: googleConnected ? 'Google vinculado' : 'Requiere vincular Google',
                  icon: Icons.cloud_upload_rounded,
                  isCompleted: currentStep >= 3,
                  isCurrent: currentStep == 2,
                  isEnabled: currentStep >= 2 && googleConnected,
                  isProcessing: isProcessing && currentStep == 2,
                  onTap: currentStep >= 2 && googleConnected && !isProcessing
                      ? onSendBigQuery
                      : null,
                  showWarning: currentStep >= 2 && !googleConnected,
                ),
                _StepConnector(isActive: currentStep >= 3),
                _StepTile(
                  step: 4,
                  label: 'Resetear estadísticas',
                  subtitle: 'Limpiar pg_stat_statements',
                  icon: Icons.restart_alt_rounded,
                  isCompleted: currentStep >= 4,
                  isCurrent: currentStep == 3,
                  isEnabled: currentStep >= 3,
                  isProcessing: isProcessing && currentStep == 3,
                  onTap: currentStep >= 3 && !isProcessing ? onReset : null,
                  isDanger: true,
                ),
              ],
            ),
          ),

          // Status message
          if (statusMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (isError == true)
                      ? const Color(0xFFFEF2F2)
                      : isComplete
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFF8FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (isError == true)
                        ? const Color(0xFFFECACA)
                        : isComplete
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFE8ECF0),
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
                      Icon(
                        (isError == true)
                            ? Icons.error_outline_rounded
                            : isComplete
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                        size: 16,
                        color: (isError == true)
                            ? const Color(0xFFDC2626)
                            : isComplete
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF0E3520),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusMessage!,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: (isError == true)
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF0E3520),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressRing() {
    final double progress = currentStep / 4;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: const Color(0xFF0E3520).withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E3520)),
          ),
          Text(
            '${currentStep}/4',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E3520),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int step;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final bool isEnabled;
  final bool isProcessing;
  final bool isDanger;
  final bool showWarning;
  final VoidCallback? onTap;

  const _StepTile({
    required this.step,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.isEnabled,
    required this.isProcessing,
    this.isDanger = false,
    this.showWarning = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFFF0FDF4)
              : isCurrent
                  ? Colors.white
                  : const Color(0xFFFAFCFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFFBBF7D0)
                : isCurrent
                    ? const Color(0xFF0E3520)
                    : isEnabled
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFFF1F5F9),
            width: isCurrent ? 1.5 : 1,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: const Color(0xFF0E3520).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Step number / check
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF0E3520)
                    : isCurrent
                        ? const Color(0xFF0E3520).withOpacity(0.1)
                        : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isProcessing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0E3520),
                        ),
                      )
                    : isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : Text(
                            '$step',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isCurrent
                                  ? const Color(0xFF0E3520)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 14),

            // Icon
            Icon(
              icon,
              size: 20,
              color: isCompleted
                  ? const Color(0xFF0E3520)
                  : isEnabled
                      ? const Color(0xFF0E3520).withOpacity(0.7)
                      : const Color(0xFFCBD5E1),
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isEnabled || isCompleted
                          ? const Color(0xFF0E3520)
                          : const Color(0xFFCBD5E1),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: showWarning
                          ? const Color(0xFFF59E0B)
                          : isEnabled || isCompleted
                              ? const Color(0xFF0E3520).withOpacity(0.45)
                              : const Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),

            // Warning icon
            if (showWarning)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
              ),

            // Arrow for current
            if (isCurrent && isEnabled && !isProcessing)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3520),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isActive;

  const _StepConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF0E3520).withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}