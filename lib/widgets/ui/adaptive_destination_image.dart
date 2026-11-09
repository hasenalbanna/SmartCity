import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// Ultra-fast, zero-storage country-adaptive destination image widget.
/// 
/// Handles network URLs, base64 strings, and local assets.
/// If a network URL fails (e.g. CORS on Web or offline), it NEVER falls back
/// to a mismatched foreign image. Instead, it renders a high-performance procedural
/// vector landscape tailored to the specific country (Manhattan skyline & bridges for US,
/// Fuji & Torii gates for Japan, Big Ben & Thames for UK, etc.).
class AdaptiveDestinationImage extends StatelessWidget {
  final String imageUrl;
  final String? country;
  final String? placeName;
  final String? category;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AdaptiveDestinationImage({
    super.key,
    required this.imageUrl,
    this.country,
    this.placeName,
    this.category,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    final trimmed = imageUrl.trim();

    if (trimmed.isEmpty) {
      child = _buildProceduralFallback(context);
    } else if (trimmed.startsWith('data:image')) {
      try {
        final commaIdx = trimmed.indexOf(',');
        final bytes = base64Decode(trimmed.substring(commaIdx + 1));
        child = Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _buildProceduralFallback(context),
        );
      } catch (_) {
        child = _buildProceduralFallback(context);
      }
    } else if (trimmed.startsWith('assets/')) {
      child = Image.asset(
        trimmed,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _buildProceduralFallback(context),
      );
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      child = Image.network(
        trimmed,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _buildProceduralFallback(context),
      );
    } else {
      child = _buildProceduralFallback(context);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    return child;
  }

  Widget _buildProceduralFallback(BuildContext context) {
    return CountryProceduralCanvas(
      country: country,
      placeName: placeName,
      category: category,
      width: width,
      height: height,
    );
  }
}

/// Zero-storage procedural vector landscape painter tuned for specific countries.
class CountryProceduralCanvas extends StatelessWidget {
  final String? country;
  final String? placeName;
  final String? category;
  final double? width;
  final double? height;

  const CountryProceduralCanvas({
    super.key,
    this.country,
    this.placeName,
    this.category,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = (country ?? '').toLowerCase();

    // Identify country profile
    _CountryVectorTheme theme;
    if (c.contains('united states') ||
        c.contains('america') ||
        c.contains('usa') ||
        c == 'us') {
      theme = _CountryVectorTheme.unitedStates(isDark);
    } else if (c.contains('japan') || c.contains('tokyo') || c == 'jp') {
      theme = _CountryVectorTheme.japan(isDark);
    } else if (c.contains('united kingdom') ||
        c.contains('london') ||
        c.contains('britain') ||
        c == 'gb' ||
        c == 'uk') {
      theme = _CountryVectorTheme.unitedKingdom(isDark);
    } else if (c.contains('emirates') ||
        c.contains('dubai') ||
        c == 'ae' ||
        c.contains('uae')) {
      theme = _CountryVectorTheme.dubai(isDark);
    } else if (c.contains('sri lanka') || c == 'lk') {
      theme = _CountryVectorTheme.sriLanka(isDark);
    } else {
      theme = _CountryVectorTheme.global(isDark);
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _ProceduralVectorPainter(theme: theme),
            size: Size.infinite,
          ),
          // Subtle landmark identifier badge in corner
          if (placeName != null && placeName!.isNotEmpty)
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: AppRadius.smBorder,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      theme.flag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        placeName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _VectorArchetype {
  skyscrapersBridges, // US (NYC, Chicago, SF)
  fujiTorii,          // Japan
  clockTowerBridge,   // UK
  futuristicNeedle,   // UAE Dubai
  lionRockTropical,   // Sri Lanka
  celestialGlobe,     // Global
}

class _CountryVectorTheme {
  final String flag;
  final _VectorArchetype archetype;
  final List<Color> skyGradient;
  final Color silhouetteColor;
  final Color accentColor;
  final Color ambientLight;

  const _CountryVectorTheme({
    required this.flag,
    required this.archetype,
    required this.skyGradient,
    required this.silhouetteColor,
    required this.accentColor,
    required this.ambientLight,
  });

  factory _CountryVectorTheme.unitedStates(bool isDark) {
    return _CountryVectorTheme(
      flag: '🇺🇸',
      archetype: _VectorArchetype.skyscrapersBridges,
      skyGradient: isDark
          ? const [
              Color(0xFF0B132B), // Midnight deep navy
              Color(0xFF1C2541), // Twilight indigo
              Color(0xFF3A506B), // Horizon blue-gray
              Color(0xFF6B4E71), // Sunset plum
            ]
          : const [
              Color(0xFF1A365D), // Rich navy
              Color(0xFF2B6CB0), // Mid blue
              Color(0xFFE28743), // Sunset amber
            ],
      silhouetteColor: isDark ? const Color(0xFF070B16) : const Color(0xFF1A202C),
      accentColor: const Color(0xFF60A5FA),
      ambientLight: const Color(0xFFFBBF24),
    );
  }

  factory _CountryVectorTheme.japan(bool isDark) {
    return _CountryVectorTheme(
      flag: '🇯🇵',
      archetype: _VectorArchetype.fujiTorii,
      skyGradient: isDark
          ? const [
              Color(0xFF15002E),
              Color(0xFF3B0764),
              Color(0xFF701A75),
              Color(0xFFF43F5E),
            ]
          : const [
              Color(0xFF4C1D95),
              Color(0xFF8B5CF6),
              Color(0xFFFDA4AF),
            ],
      silhouetteColor: isDark ? const Color(0xFF090014) : const Color(0xFF2E1065),
      accentColor: const Color(0xFFF472B6),
      ambientLight: const Color(0xFFFFD166),
    );
  }

  factory _CountryVectorTheme.unitedKingdom(bool isDark) {
    return _CountryVectorTheme(
      flag: '🇬🇧',
      archetype: _VectorArchetype.clockTowerBridge,
      skyGradient: isDark
          ? const [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
              Color(0xFF64748B),
            ]
          : const [
              Color(0xFF1E293B),
              Color(0xFF475569),
              Color(0xFF94A3B8),
            ],
      silhouetteColor: isDark ? const Color(0xFF060911) : const Color(0xFF0F172A),
      accentColor: const Color(0xFF93C5FD),
      ambientLight: const Color(0xFFFCD34D),
    );
  }

  factory _CountryVectorTheme.dubai(bool isDark) {
    return _CountryVectorTheme(
      flag: '🇦🇪',
      archetype: _VectorArchetype.futuristicNeedle,
      skyGradient: isDark
          ? const [
              Color(0xFF0D0F14),
              Color(0xFF1E1B18),
              Color(0xFF3E2D18),
              Color(0xFF854D0E),
            ]
          : const [
              Color(0xFF1C1917),
              Color(0xFF78350F),
              Color(0xFFCA8A04),
            ],
      silhouetteColor: isDark ? const Color(0xFF050608) : const Color(0xFF1C1917),
      accentColor: const Color(0xFFFBBF24),
      ambientLight: const Color(0xFFFEF08A),
    );
  }

  factory _CountryVectorTheme.sriLanka(bool isDark) {
    return _CountryVectorTheme(
      flag: '🇱🇰',
      archetype: _VectorArchetype.lionRockTropical,
      skyGradient: isDark
          ? const [
              Color(0xFF061A12),
              Color(0xFF064E3B),
              Color(0xFF047857),
              Color(0xFFD97706),
            ]
          : const [
              Color(0xFF064E3B),
              Color(0xFF059669),
              Color(0xFFF59E0B),
            ],
      silhouetteColor: isDark ? const Color(0xFF020E09) : const Color(0xFF064E3B),
      accentColor: const Color(0xFF34D399),
      ambientLight: const Color(0xFFFDE68A),
    );
  }

  factory _CountryVectorTheme.global(bool isDark) {
    return _CountryVectorTheme(
      flag: '🌐',
      archetype: _VectorArchetype.celestialGlobe,
      skyGradient: isDark
          ? const [
              Color(0xFF09090B),
              Color(0xFF18181B),
              Color(0xFF27272A),
              Color(0xFF3F3F46),
            ]
          : const [
              Color(0xFF18181B),
              Color(0xFF3F3F46),
              Color(0xFF71717A),
            ],
      silhouetteColor: isDark ? const Color(0xFF000000) : const Color(0xFF18181B),
      accentColor: const Color(0xFFA1A1AA),
      ambientLight: const Color(0xFFFFFFFF),
    );
  }
}

class _ProceduralVectorPainter extends CustomPainter {
  final _CountryVectorTheme theme;

  _ProceduralVectorPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw atmospheric sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: theme.skyGradient,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Draw subtle star / ambient particles
    final random = math.Random(theme.archetype.index * 997);
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (int i = 0; i < 28; i++) {
      final dx = random.nextDouble() * w;
      final dy = random.nextDouble() * (h * 0.55);
      final radius = random.nextDouble() * 1.2 + 0.5;
      canvas.drawCircle(Offset(dx, dy), radius, dotPaint);
    }

    // 3. Draw iconic country vector silhouette
    switch (theme.archetype) {
      case _VectorArchetype.skyscrapersBridges:
        _drawSkyscrapersAndBridge(canvas, size);
        break;
      case _VectorArchetype.fujiTorii:
        _drawFujiAndTorii(canvas, size);
        break;
      case _VectorArchetype.clockTowerBridge:
        _drawClockTowerAndBridge(canvas, size);
        break;
      case _VectorArchetype.futuristicNeedle:
        _drawFuturisticNeedle(canvas, size);
        break;
      case _VectorArchetype.lionRockTropical:
        _drawLionRock(canvas, size);
        break;
      case _VectorArchetype.celestialGlobe:
        _drawGlobeGrid(canvas, size);
        break;
    }

    // 4. Ambient ground reflection / vignette
    final vignettePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.70),
        ],
        stops: const [0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), vignettePaint);
  }

  void _drawSkyscrapersAndBridge(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = h * 0.88;

    final buildingPaint = Paint()..color = theme.silhouetteColor;
    final windowPaint = Paint()..color = theme.ambientLight.withValues(alpha: 0.40);

    // Background skyline towers
    final towers = [
      Rect.fromLTWH(w * 0.04, h * 0.38, w * 0.12, h),
      Rect.fromLTWH(w * 0.18, h * 0.28, w * 0.14, h), // Empire state style
      Rect.fromLTWH(w * 0.34, h * 0.44, w * 0.11, h),
      Rect.fromLTWH(w * 0.47, h * 0.22, w * 0.16, h), // Tall spire
      Rect.fromLTWH(w * 0.65, h * 0.35, w * 0.13, h),
      Rect.fromLTWH(w * 0.80, h * 0.48, w * 0.16, h),
    ];

    for (final r in towers) {
      canvas.drawRect(r, buildingPaint);
      // Windows
      for (double y = r.top + 8; y < base - 10; y += 12) {
        for (double x = r.left + 5; x < r.right - 5; x += 9) {
          canvas.drawRect(Rect.fromLTWH(x, y, 4, 5), windowPaint);
        }
      }
    }

    // Spire needle on the tallest tower
    final spireX = w * 0.55;
    final spirePaint = Paint()
      ..color = theme.silhouetteColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(spireX, h * 0.22), Offset(spireX, h * 0.12), spirePaint);

    // Glowing tip
    final tipPaint = Paint()..color = theme.accentColor;
    canvas.drawCircle(Offset(spireX, h * 0.12), 2.5, tipPaint);

    // Bridge suspension cables silhouette across foreground
    final cablePaint = Paint()
      ..color = theme.silhouetteColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cablePath = Path()
      ..moveTo(0, h * 0.70)
      ..quadraticBezierTo(w * 0.25, h * 0.82, w * 0.50, h * 0.70)
      ..quadraticBezierTo(w * 0.75, h * 0.82, w, h * 0.70);
    canvas.drawPath(cablePath, cablePaint);

    // Bridge tower uprights
    canvas.drawRect(Rect.fromLTWH(w * 0.23, h * 0.60, w * 0.04, h * 0.4), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.73, h * 0.60, w * 0.04, h * 0.4), buildingPaint);
  }

  void _drawFujiAndTorii(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Symmetrical Mt. Fuji
    final fujiPath = Path()
      ..moveTo(w * 0.10, h)
      ..lineTo(w * 0.42, h * 0.36)
      ..lineTo(w * 0.58, h * 0.36)
      ..lineTo(w * 0.90, h)
      ..close();

    final fujiPaint = Paint()..color = theme.silhouetteColor;
    canvas.drawPath(fujiPath, fujiPaint);

    // Snowcap on Fuji
    final snowPath = Path()
      ..moveTo(w * 0.42, h * 0.36)
      ..lineTo(w * 0.58, h * 0.36)
      ..lineTo(w * 0.64, h * 0.48)
      ..lineTo(w * 0.58, h * 0.46)
      ..lineTo(w * 0.50, h * 0.52)
      ..lineTo(w * 0.42, h * 0.46)
      ..lineTo(w * 0.36, h * 0.48)
      ..close();
    final snowPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
    canvas.drawPath(snowPath, snowPaint);

    // Torii Gate in foreground
    final toriiPaint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    // Top beam
    final topBeam = Path()
      ..moveTo(w * 0.18, h * 0.68)
      ..quadraticBezierTo(w * 0.35, h * 0.71, w * 0.52, h * 0.68)
      ..lineTo(w * 0.50, h * 0.72)
      ..quadraticBezierTo(w * 0.35, h * 0.74, w * 0.20, h * 0.72)
      ..close();
    canvas.drawPath(topBeam, toriiPaint);

    // Second beam
    canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.74, w * 0.26, 4), toriiPaint);

    // Pillars
    canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.71, w * 0.03, h * 0.29), toriiPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.71, w * 0.03, h * 0.29), toriiPaint);
  }

  void _drawClockTowerAndBridge(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final darkPaint = Paint()..color = theme.silhouetteColor;

    // Big Ben Spire
    final spire = Path()
      ..moveTo(w * 0.18, h * 0.40)
      ..lineTo(w * 0.23, h * 0.18) // Spire tip
      ..lineTo(w * 0.28, h * 0.40)
      ..close();
    canvas.drawPath(spire, darkPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.17, h * 0.40, w * 0.12, h * 0.6), darkPaint);

    // Clock Face glow
    final clockPaint = Paint()..color = theme.ambientLight.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(w * 0.23, h * 0.46), 7, clockPaint);

    // Tower Bridge twin towers silhouette
    canvas.drawRect(Rect.fromLTWH(w * 0.55, h * 0.52, w * 0.08, h * 0.48), darkPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.75, h * 0.52, w * 0.08, h * 0.48), darkPaint);

    // Bridge walkway
    canvas.drawRect(Rect.fromLTWH(w * 0.55, h * 0.62, w * 0.28, 5), darkPaint);
  }

  void _drawFuturisticNeedle(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final darkPaint = Paint()..color = theme.silhouetteColor;

    // Burj Khalifa tiered spire
    final burj = Path()
      ..moveTo(w * 0.48, h)
      ..lineTo(w * 0.48, h * 0.10) // Needle
      ..lineTo(w * 0.52, h * 0.10)
      ..lineTo(w * 0.52, h)
      ..close();
    canvas.drawPath(burj, darkPaint);

    // Tiered wings
    canvas.drawRect(Rect.fromLTWH(w * 0.44, h * 0.35, w * 0.12, h * 0.65), darkPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.40, h * 0.55, w * 0.20, h * 0.45), darkPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.72, w * 0.30, h * 0.28), darkPaint);

    // Spire beacon
    final beacon = Paint()..color = theme.accentColor;
    canvas.drawCircle(Offset(w * 0.50, h * 0.10), 3, beacon);
  }

  void _drawLionRock(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final darkPaint = Paint()..color = theme.silhouetteColor;

    // Sigiriya monolithic rock profile
    final rock = Path()
      ..moveTo(w * 0.15, h)
      ..lineTo(w * 0.25, h * 0.48)
      ..quadraticBezierTo(w * 0.35, h * 0.40, w * 0.55, h * 0.40)
      ..lineTo(w * 0.78, h * 0.45)
      ..lineTo(w * 0.85, h)
      ..close();
    canvas.drawPath(rock, darkPaint);
  }

  void _drawGlobeGrid(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final arcPaint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(w * 0.5, h * 0.65);
    canvas.drawCircle(center, w * 0.38, arcPaint);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.76, height: h * 0.4),
      arcPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.38, height: h * 0.7),
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProceduralVectorPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
