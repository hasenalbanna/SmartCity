import 'package:flutter/material.dart';

/// Semantic color tokens for Smart City (WCAG AA compliant).
class AppColors {
  AppColors._();

  // Brand Primary
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF60A5FA);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF0B1220);

  // Surfaces & Backgrounds (Clean Minimal True-Black Dark Mode & Pure White Light Mode)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0A0A0A);
  static const Color surfaceMutedLight = Color(0xFFF4F4F5);
  static const Color surfaceMutedDark = Color(0xFF141414);

  // Borders & Dividers
  static const Color outlineLight = Color(0xFFE4E4E7);
  static const Color outlineDark = Color(0xFF27272A);

  // Text Hierarchy
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Semantic Status Colors
  static const Color successLight = Color(0xFF16A34A);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color successBgLight = Color(0xFFDCFCE7);
  static const Color successBgDark = Color(0xFF052E16);

  static const Color warningLight = Color(0xFFD97706);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningBgLight = Color(0xFFFEF3C7);
  static const Color warningBgDark = Color(0xFF451A03);

  static const Color dangerLight = Color(0xFFDC2626);
  static const Color dangerDark = Color(0xFFF87171);
  static const Color dangerBgLight = Color(0xFFFEE2E2);
  static const Color dangerBgDark = Color(0xFF450A0A);

  static const Color infoLight = Color(0xFF2563EB);
  static const Color infoDark = Color(0xFF60A5FA);
  static const Color infoBgLight = Color(0xFFDBEAFE);
  static const Color infoBgDark = Color(0xFF172554);

  // Context-aware helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primary(BuildContext context) =>
      isDark(context) ? primaryDark : primaryLight;

  static Color background(BuildContext context) =>
      isDark(context) ? backgroundDark : backgroundLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? surfaceDark : surfaceLight;

  static Color surfaceMuted(BuildContext context) =>
      isDark(context) ? surfaceMutedDark : surfaceMutedLight;

  static Color outline(BuildContext context) =>
      isDark(context) ? outlineDark : outlineLight;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color success(BuildContext context) =>
      isDark(context) ? successDark : successLight;

  static Color successBg(BuildContext context) =>
      isDark(context) ? successBgDark : successBgLight;

  static Color warning(BuildContext context) =>
      isDark(context) ? warningDark : warningLight;

  static Color warningBg(BuildContext context) =>
      isDark(context) ? warningBgDark : warningBgLight;

  static Color danger(BuildContext context) =>
      isDark(context) ? dangerDark : dangerLight;

  static Color dangerBg(BuildContext context) =>
      isDark(context) ? dangerBgDark : dangerBgLight;

  static Color info(BuildContext context) =>
      isDark(context) ? infoDark : infoLight;

  static Color infoBg(BuildContext context) =>
      isDark(context) ? infoBgDark : infoBgLight;
}

