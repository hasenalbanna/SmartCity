import 'package:flutter/material.dart';

/// Luxury Monochrome Black, White & Architectural Gray Design System.
/// Zero generic blue — pure obsidian black, subtle premium charcoal gradients,
/// crisp white typography, and refined platinum/graphite grays.
class AppColors {
  AppColors._();

  // Brand Primary (Pure Black in Light Mode, Pure White in Dark Mode — NO BLUE)
  static const Color primaryLight = Color(0xFF09090B);
  static const Color primaryDark = Color(0xFFFFFFFF);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF000000);

  // Surfaces & Backgrounds (Plain Deep Black + Dark Obsidian Cards in Dark Mode)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0E0E11);
  static const Color surfaceMutedLight = Color(0xFFF4F4F5);
  static const Color surfaceMutedDark = Color(0xFF18181C);

  // Subtle Luxury Background Gradients (Black -> Deep Charcoal Obsidian)
  static const LinearGradient darkPremiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [
      Color(0xFF000000),
      Color(0xFF0A0A0D),
      Color(0xFF141419),
    ],
  );

  static const LinearGradient lightPremiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAFAFA),
      Color(0xFFF4F4F5),
    ],
  );

  // Borders & Dividers
  static const Color outlineLight = Color(0xFFE4E4E7);
  static const Color outlineDark = Color(0xFF27272A);

  // Text Hierarchy (Pure White on Dark Black, Crisp Black on White)
  static const Color textPrimaryLight = Color(0xFF09090B);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF52525B);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);

  // Monochrome Status Hierarchy (Refined White, Platinum, Silver & Graphite — Zero Blue)
  static const Color successLight = Color(0xFF09090B);
  static const Color successDark = Color(0xFFFFFFFF);
  static const Color successBgLight = Color(0xFFF4F4F5);
  static const Color successBgDark = Color(0xFF18181B);

  static const Color warningLight = Color(0xFF27272A);
  static const Color warningDark = Color(0xFFE4E4E7);
  static const Color warningBgLight = Color(0xFFF4F4F5);
  static const Color warningBgDark = Color(0xFF1F1F23);

  static const Color dangerLight = Color(0xFF09090B);
  static const Color dangerDark = Color(0xFFFFFFFF);
  static const Color dangerBgLight = Color(0xFFE4E4E7);
  static const Color dangerBgDark = Color(0xFF27272A);

  static const Color infoLight = Color(0xFF18181B);
  static const Color infoDark = Color(0xFFF4F4F5);
  static const Color infoBgLight = Color(0xFFF4F4F5);
  static const Color infoBgDark = Color(0xFF18181B);

  // Context-aware helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static LinearGradient backgroundGradient(BuildContext context) =>
      isDark(context) ? darkPremiumGradient : lightPremiumGradient;

  static Color primary(BuildContext context) =>
      isDark(context) ? primaryDark : primaryLight;

  static Color onPrimary(BuildContext context) =>
      isDark(context) ? onPrimaryDark : onPrimaryLight;

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

  // Feature & KPI Accent Colors for Dark and Light Modes
  static const Color accentBlueLight = Color(0xFF2563EB);
  static const Color accentBlueDark = Color(0xFF60A5FA);

  static const Color accentGreenLight = Color(0xFF059669);
  static const Color accentGreenDark = Color(0xFF34D399);

  static const Color accentPurpleLight = Color(0xFF7C3AED);
  static const Color accentPurpleDark = Color(0xFFA78BFA);

  static const Color accentAmberLight = Color(0xFFD97706);
  static const Color accentAmberDark = Color(0xFFFBBF24);

  static const Color accentRoseLight = Color(0xFFE11D48);
  static const Color accentRoseDark = Color(0xFFFB7185);

  static const Color accentTealLight = Color(0xFF0D9488);
  static const Color accentTealDark = Color(0xFF2DD4BF);

  static Color accentBlue(BuildContext context) =>
      isDark(context) ? accentBlueDark : accentBlueLight;

  static Color accentGreen(BuildContext context) =>
      isDark(context) ? accentGreenDark : accentGreenLight;

  static Color accentPurple(BuildContext context) =>
      isDark(context) ? accentPurpleDark : accentPurpleLight;

  static Color accentAmber(BuildContext context) =>
      isDark(context) ? accentAmberDark : accentAmberLight;

  static Color accentRose(BuildContext context) =>
      isDark(context) ? accentRoseDark : accentRoseLight;

  static Color accentTeal(BuildContext context) =>
      isDark(context) ? accentTealDark : accentTealLight;
}
