import 'dart:async';
import 'package:flutter/material.dart';

class EmergencyBeaconModal extends StatefulWidget {
  const EmergencyBeaconModal({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, _, __) => const EmergencyBeaconModal(),
    );
  }

  @override
  State<EmergencyBeaconModal> createState() => _EmergencyBeaconModalState();
}

class _EmergencyBeaconModalState extends State<EmergencyBeaconModal> {
  Timer? _strobeTimer;
  bool _isBright = false;

  @override
  void initState() {
    super.initState();
    _strobeTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (mounted) {
        setState(() => _isBright = !_isBright);
      }
    });
  }

  @override
  void dispose() {
    _strobeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isBright ? const Color(0xFFEF4444) : Colors.white;
    final fgColor = _isBright ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_rounded, color: fgColor, size: 84),
              const SizedBox(height: 24),
              Text(
                'EMERGENCY SOS BEACON',
                style: TextStyle(
                  color: fgColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'HIGH INTENSITY VISUAL SEARCH STROBE',
                style: TextStyle(
                  color: fgColor.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 12,
                ),
                icon: const Icon(Icons.stop_circle_rounded, size: 24, color: Color(0xFFEF4444)),
                label: const Text(
                  'DEACTIVATE BEACON',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

