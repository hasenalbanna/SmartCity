import 'dart:math';

import 'package:flutter/material.dart';

class LiquidBackground extends StatelessWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? null
                : const Color(0xFFFAFAFA), // Premium off-white/grayish base
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B0D12),
                      Color(0xFF10141C),
                      Color(0xFF151A24),
                    ],
                  )
                : null, // No gradient in light mode
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _GrainPainter(isDark: isDark)),
          ),
        ),
        child,
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  final bool isDark;

  _GrainPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    // Increase grain density slightly for a richer texture
    final points = (size.width * size.height / 700).round();
    for (var i = 0; i < points; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final alpha = isDark
          ? (0.02 + rnd.nextDouble() * 0.05)
          : (0.03 +
                rnd.nextDouble() *
                    0.04); // Slightly darker grain for light mode

      paint.color = isDark
          ? Colors.white.withValues(alpha: alpha)
          : Colors.black.withValues(
              alpha: alpha,
            ); // Dark grain on light background
      canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
