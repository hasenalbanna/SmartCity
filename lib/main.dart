import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'services/community_issue_service.dart';
import 'services/smart_bus_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCityApp());
}

class SmartCityApp extends StatelessWidget {
  const SmartCityApp({super.key});

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
        ChangeNotifierProvider(create: (_) => CommunityIssueService()),
        ChangeNotifierProvider(create: (_) => SmartBusService()),
      ],
      child: Consumer2<LocalizationService, ThemeService>(
        builder: (context, localization, themeService, child) {
          return MaterialApp(
            title: 'Smart City',
            debugShowCheckedModeBanner: false,
            locale: _getLocale(localization.currentLanguage),
            themeMode: themeService.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
