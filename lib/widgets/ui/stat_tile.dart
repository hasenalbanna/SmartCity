import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Reusable executive KPI Stat Tile featuring dynamic ambient mesh patterns,
/// watermark icon glyphs, dark/light adaptive gradients, and high-contrast typography.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary(context);
    final color = accentColor ?? primary;

    // Adaptive card background colors
    final bgStart = isDark
        ? Color.lerp(const Color(0xFF131722), color, 0.08)!
        : Color.lerp(Colors.white, color, 0.04)!;
    final bgEnd = isDark
        ? const Color(0xFF0A0D14)
        : const Color(0xFFF5F7FA);

    return Semantics(
      label: '$label: $value',
      button: onTap != null,
      child: ClipRRect(
        borderRadius: AppRadius.mdBorder,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgStart, bgEnd],
            ),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.30 : 0.20),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.12 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.mdBorder,
              child: Stack(
                children: [
                  // 1. Procedural Vector Wave & Mesh Background Pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StatTilePatternPainter(
                        color: color,
                        isDark: isDark,
                      ),
                    ),
                  ),

                  // 2. Large Translucent Watermark Glyph
                  Positioned(
                    right: -6,
                    bottom: -8,
                    child: IgnorePointer(
                      child: Icon(
                        icon,
                        size: 58,
                        color: color.withValues(alpha: isDark ? 0.09 : 0.06),
                      ),
                    ),
                  ),

                  // 3. Crisp Card Content
                  Padding(
                    padding: const EdgeInsets.all(AppSpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Header Row: Icon Container + External Navigation Arrow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                                borderRadius: BorderRadius.circular(AppSpace.sm),
                                border: Border.all(
                                  color: color.withValues(alpha: isDark ? 0.40 : 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Icon(icon, size: 19, color: color),
                            ),
                            if (onTap != null)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.06),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 13,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : Colors.black.withValues(alpha: 0.65),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.md),

                        // Metric Numerical Value (High-Contrast Display Font)
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.display.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            shadows: isDark
                                ? [
                                    Shadow(
                                      color: color.withValues(alpha: 0.40),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Metric Label with High-Contrast Secondary Color
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom vector painter creating organic waves, contour lines and concentric radar ripples.
class _StatTilePatternPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _StatTilePatternPainter({
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.08 : 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Concentric ambient ripples in top-right
    final center = Offset(size.width * 0.9, size.height * 0.1);
    for (int r = 1; r <= 3; r++) {
      canvas.drawCircle(center, r * 18.0, wavePaint);
    }

    // 2. Smooth S-curve across lower third
    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.60,
      size.width,
      size.height * 0.85,
    );
    canvas.drawPath(path, wavePaint);

    // 3. Secondary contour curve
    final path2 = Path();
    path2.moveTo(0, size.height * 0.90);
    path2.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.75,
      size.width,
      size.height * 0.98,
    );
    canvas.drawPath(path2, wavePaint);

    // 4. Subtle glowing radial highlight in top-left
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: isDark ? 0.10 : 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: const Offset(18, 18), radius: 48));
    canvas.drawCircle(const Offset(18, 18), 48, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _StatTilePatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}
