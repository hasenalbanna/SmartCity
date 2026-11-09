import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Unified premium typography scale (Plus Jakarta Sans + system fallbacks, minimum 12px).
/// Designed for luxury civic dashboards, crisp geometric readability, and balanced kerning.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Plus Jakarta Sans';
  static const List<String> fontFallback = [
    'Plus Jakarta Sans',
    'Inter',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Noto Sans Tamil',
    'Arial',
    'sans-serif',
  ];

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.8,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: -0.1,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: -0.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.05,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.15,
  );

  static TextTheme textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final base = TextTheme(
      displayLarge: display.copyWith(color: primary),
      displayMedium: display.copyWith(fontSize: 24, letterSpacing: -0.6, color: primary),
      displaySmall: display.copyWith(fontSize: 22, letterSpacing: -0.5, color: primary),
      headlineMedium: display.copyWith(fontSize: 22, color: primary),
      titleLarge: title.copyWith(color: primary),
      titleMedium: subtitle.copyWith(color: primary),
      titleSmall: subtitle.copyWith(fontSize: 14, color: primary),
      bodyLarge: bodyStrong.copyWith(color: primary),
      bodyMedium: body.copyWith(color: primary),
      bodySmall: caption.copyWith(color: secondary),
      labelLarge: button.copyWith(color: primary),
      labelMedium: caption.copyWith(color: secondary),
      labelSmall: caption.copyWith(fontSize: 12, color: secondary),
    );

    try {
      return GoogleFonts.plusJakartaSansTextTheme(base);
    } catch (_) {
      return base;
    }
  }
}

