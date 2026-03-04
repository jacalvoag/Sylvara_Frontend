import 'package:flutter/material.dart';

class GoogleStatusCard extends StatelessWidget {
  final bool isConnected;
  final bool isLoading;
  final VoidCallback onConnect;

  const GoogleStatusCard({
    super.key,
    required this.isConnected,
    required this.isLoading,
    required this.onConnect,
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
          color: isConnected ? const Color(0xFF0E3520) : const Color(0xFFE0E0E0),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isConnected
                  ? const Color(0xFF0E3520).withOpacity(0.1)
                  : const Color(0xFFE0E0E0).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: isConnected ? const Color(0xFF0E3520) : const Color(0xFF757575),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Google BigQuery',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0E3520),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isConnected ? 'Conectado' : 'No conectado',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isConnected ? const Color(0xFF0E3520) : const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          if (!isConnected)
            GestureDetector(
              onTap: isLoading ? null : onConnect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3520),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Conectar',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          if (isConnected)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF0E3520),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }
}