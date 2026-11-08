import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'ui/ui.dart';

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
    _strobeTimer = Timer.periodic(const Duration(milliseconds: 240), (_) {
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
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final activeFlash = !disableAnimations && _isBright;
    final bgColor = activeFlash ? AppColors.dangerLight : Colors.white;
    final fgColor = activeFlash ? Colors.white : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(Icons.sos_rounded, size: 88, color: fgColor),
              const SizedBox(height: AppSpace.lg),
              Text(
                'EMERGENCY VISUAL BEACON',
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(color: fgColor),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                'High-visibility strobe active for first responders in Nintavur.',
                textAlign: TextAlign.center,
                style: AppTypography.subtitle.copyWith(color: fgColor),
              ),
              const Spacer(),
              AppButton(
                label: 'Turn Off Beacon',
                icon: Icons.close_rounded,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
