import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherPoint {
  final double temperatureC;
  final int weatherCode;
  final double windKph;

  const WeatherPoint({
    required this.temperatureC,
    required this.weatherCode,
    required this.windKph,
  });

  Map<String, dynamic> toJson() => {
    'temperatureC': temperatureC,
    'weatherCode': weatherCode,
    'windKph': windKph,
  };

  factory WeatherPoint.fromJson(Map<String, dynamic> json) {
    return WeatherPoint(
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 0,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
      windKph: (json['windKph'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WeatherService extends ChangeNotifier {
  static const String _cacheKey = 'smartcity_weather_cache_v1';
  static const Duration _refreshInterval = Duration(minutes: 15);

  static const Map<String, ({double lat, double lon})> _provinceCoords = {
    'Central': (lat: 7.2906, lon: 80.6337),
    'Western': (lat: 6.9271, lon: 79.8612),
    'Southern': (lat: 6.0535, lon: 80.2210),
    'Eastern': (lat: 7.7190, lon: 81.7000),
    'Uva': (lat: 6.9934, lon: 81.0550),
    'North Central': (lat: 8.3114, lon: 80.4037),
    'North Western': (lat: 7.4863, lon: 80.3623),
    'Northern': (lat: 9.6615, lon: 80.0255),
    'Sabaragamuwa': (lat: 6.7056, lon: 80.3847),
  };

  WeatherPoint? _currentWeather;
  final Map<String, WeatherPoint> _provinceWeather = {};
  DateTime? _lastUpdated;
  bool _isLoading = false;
  String _currentLabel = 'Current Location';
  String _preferredCity = 'New York';
  double _fallbackLat = 40.7128;
  double _fallbackLon = -74.0060;
  Timer? _timer;

  WeatherService() {
    _bootstrap();
  }

  void setPreferredLocation({
    required String city,
    required double latitude,
    required double longitude,
  }) {
    if (_preferredCity == city &&
        _fallbackLat == latitude &&
        _fallbackLon == longitude) {
      return;
    }
    _preferredCity = city;
    _fallbackLat = latitude;
    _fallbackLon = longitude;
    _currentLabel = city;
    refreshNow();
  }

  WeatherPoint? get currentWeather => _currentWeather;
  WeatherPoint? provinceWeatherOf(String province) =>
      _provinceWeather[province];
  DateTime? get lastUpdated => _lastUpdated;
  bool get isLoading => _isLoading;
  String get currentLabel => _currentLabel;

  String get updatedAgo {
    if (_lastUpdated == null) return 'Not updated';
    final diff = DateTime.now().difference(_lastUpdated!);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  Future<void> _bootstrap() async {
    await _loadCache();
    unawaited(refreshNow());
    _timer = Timer.periodic(_refreshInterval, (_) {
      unawaited(refreshNow());
    });
  }

  Future<void> refreshNow() async {
    final shouldNotifyLoading = _currentWeather == null;
    if (shouldNotifyLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final currentCoord = await _resolveUserCoord();
      _currentWeather = await _fetch(currentCoord.$1, currentCoord.$2);

      final futures = _provinceCoords.entries.map((entry) async {
        final coord = entry.value;
        final point = await _fetch(coord.lat, coord.lon);
        return MapEntry(entry.key, point);
      }).toList();

      final rows = await Future.wait(futures);
      _provinceWeather
        ..clear()
        ..addEntries(rows);
      _lastUpdated = DateTime.now();
      await _saveCache();
    } catch (_) {
      // Keep cached/previous weather on failures.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<(double, double)> _resolveUserCoord() async {
    final fallback = (_fallbackLat, _fallbackLon);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _currentLabel = _preferredCity;
        return fallback;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _currentLabel = _preferredCity;
        return fallback;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      _currentLabel = 'Current Location';
      return (position.latitude, position.longitude);
    } catch (_) {
      _currentLabel = _preferredCity;
      return fallback;
    }
  }

  Future<WeatherPoint> _fetch(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code,wind_speed_10m&timezone=auto',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Weather API failed: ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>?;
    if (current == null) throw Exception('No weather data');
    return WeatherPoint(
      temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      windKph: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final json = {
      'lastUpdated': _lastUpdated?.toIso8601String(),
      'currentLabel': _currentLabel,
      'currentWeather': _currentWeather?.toJson(),
      'provinceWeather': _provinceWeather.map(
        (k, v) => MapEntry(k, v.toJson()),
      ),
    };
    await prefs.setString(_cacheKey, jsonEncode(json));
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _currentLabel = data['currentLabel'] as String? ?? _currentLabel;
      final ts = data['lastUpdated'] as String?;
      if (ts != null) _lastUpdated = DateTime.tryParse(ts);

      final currentJson = data['currentWeather'] as Map<String, dynamic>?;
      if (currentJson != null) {
        _currentWeather = WeatherPoint.fromJson(currentJson);
      }

      final provinces = data['provinceWeather'] as Map<String, dynamic>?;
      if (provinces != null) {
        _provinceWeather
          ..clear()
          ..addEntries(
            provinces.entries.map(
              (e) => MapEntry(
                e.key,
                WeatherPoint.fromJson((e.value as Map).cast<String, dynamic>()),
              ),
            ),
          );
      }
      notifyListeners();
    } catch (_) {
      // Ignore cache decoding issues.
    }
  }

  static String weatherLabel(int code) {
    if (code == 0) return 'Clear';
    if (code == 1 || code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code == 51 || code == 53 || code == 55) return 'Drizzle';
    if (code == 61 || code == 63 || code == 65) return 'Rain';
    if (code == 66 || code == 67) return 'Freezing Rain';
    if (code == 71 || code == 73 || code == 75) return 'Snow';
    if (code == 80 || code == 81 || code == 82) return 'Rain Showers';
    if (code == 95 || code == 96 || code == 99) return 'Thunderstorm';
    return 'Weather';
  }

  static IconData weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code == 1 || code == 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code == 51 || code == 53 || code == 55) return Icons.grain_rounded;
    if (code == 61 ||
        code == 63 ||
        code == 65 ||
        code == 80 ||
        code == 81 ||
        code == 82) {
      return Icons.umbrella_rounded;
    }
    if (code == 95 || code == 96 || code == 99) {
      return Icons.thunderstorm_rounded;
    }
    return Icons.cloud_rounded;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
