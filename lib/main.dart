import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'services/social_service.dart';
import 'services/location_service.dart';
import 'services/payment_service.dart';
import 'services/localization_service.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/theme_service.dart';
import 'services/clock_service.dart';
import 'services/notification_service.dart';
import 'services/weather_service.dart';
import 'services/trip_history_service.dart';
import 'services/currency_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCityApp());
}

class SmartCityApp extends StatelessWidget {
  const SmartCityApp({super.key});

  // Map language codes to Flutter Locale
  Locale _getLocale(String languageCode) {
    switch (languageCode) {
      case 'si':
        return const Locale('si', 'LK');
      case 'ta':
        return const Locale('ta', 'IN');
      case 'hi':
        return const Locale('hi', 'IN');
      case 'fr':
        return const Locale('fr', 'FR');
      case 'ml':
        return const Locale('ml', 'IN');
      case 'kn':
        return const Locale('kn', 'IN');
      case 'de':
        return const Locale('de', 'DE');
      case 'zh':
        return const Locale('zh', 'CN');
      case 'ja':
        return const Locale('ja', 'JP');
      case 'ru':
        return const Locale('ru', 'RU');
      default:
        return const Locale('en', 'US');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocialService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProfileService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => ClockService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => WeatherService()),
        ChangeNotifierProvider(create: (_) => TripHistoryService()),
        ChangeNotifierProvider(create: (_) => CurrencyService()),
      ],
      child: Consumer2<LocalizationService, ThemeService>(
        builder: (context, localization, themeService, child) {
          TextTheme textTheme;
          try {
            textTheme = GoogleFonts.interTextTheme();
          } catch (_) {
            textTheme = ThemeData.light().textTheme;
          }

          return MaterialApp(
            title: 'Smart City',
            debugShowCheckedModeBanner: false,
            locale: _getLocale(localization.currentLanguage),
            themeMode: themeService.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: const Color(0xFF111111),
              scaffoldBackgroundColor: const Color(0xFFF7F9F9),
              splashColor: Colors.black.withValues(alpha: 0.06),
              hoverColor: Colors.black.withValues(alpha: 0.04),
              highlightColor: Colors.black.withValues(alpha: 0.03),
              textTheme: textTheme,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF111111),
                brightness: Brightness.light,
                primary: const Color(0xFF111111),
                secondary: const Color(0xFF111111),
                tertiary: const Color(0xFF111111),
                surface: const Color(0xFFFFFFFF),
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Color(0xFF0F1419),
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F1419),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    inherit: false,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                  side: const BorderSide(color: Color(0xFF111111), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                ),
              ),
              iconButtonTheme: IconButtonThemeData(
                style: IconButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFEFF3F4), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFFEAF1FF),
              scaffoldBackgroundColor: const Color(
                0xFF000000,
              ), // Tweet/X true black
              splashColor: Colors.white.withValues(alpha: 0.08),
              hoverColor: Colors.white.withValues(alpha: 0.06),
              highlightColor: Colors.white.withValues(alpha: 0.04),
              textTheme: textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFEAF1FF),
                secondary: Color(0xFFEAF1FF),
                tertiary: Color(0xFFEAF1FF),
                surface: Color(0xFF151922),
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Color(0xFFEAF1FF),
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF3F4),
                  foregroundColor: const Color(0xFF0F1419),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    inherit: false,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEAF1FF),
                  side: const BorderSide(color: Color(0xFFEAF1FF), width: 1.2),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEAF1FF),
                ),
              ),
              iconButtonTheme: IconButtonThemeData(
                style: IconButton.styleFrom(
                  foregroundColor: const Color(0xFFEAF1FF),
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF16181C), // X dark mode card color
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFF2F3336), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
