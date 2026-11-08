import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingResult {
  final String displayName;
  final LatLng location;

  GeocodingResult({required this.displayName, required this.location});
}

class _CachedGeocoding {
  final DateTime timestamp;
  final List<GeocodingResult> results;
  _CachedGeocoding(this.timestamp, this.results);
}

class GeocodingService {
  static const String _host = 'nominatim.openstreetmap.org';
  static const String _path = '/search';
  static DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _minInterval = Duration(milliseconds: 1000);
  static final Map<String, _CachedGeocoding> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 15);

  Future<List<GeocodingResult>> searchPlaces(String query) async {
    final sanitizedQuery = query.trim();
    if (sanitizedQuery.isEmpty || sanitizedQuery.length > 200) return [];

    final normalizedKey = sanitizedQuery.toLowerCase();
    final cached = _cache[normalizedKey];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheTtl) {
      return cached.results;
    }

    // Enforce rate limiting: max 1 request/sec to adhere to Nominatim AUP
    final now = DateTime.now();
    final elapsed = now.difference(_lastRequestTime);
    if (elapsed < _minInterval) {
      await Future.delayed(_minInterval - elapsed);
    }
    _lastRequestTime = DateTime.now();

    final uri = Uri.https(
      _host,
      _path,
      {
        'q': sanitizedQuery,
        'format': 'json',
        'limit': '5',
      },
    );
    
    try {
      final response = await http.get(
        uri, 
        headers: {'User-Agent': 'SmartCity/1.0 (https://smartcity.local)'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final results = <GeocodingResult>[];
        for (final item in data) {
          if (item is Map) {
            final lat = double.tryParse(item['lat']?.toString() ?? '');
            final lon = double.tryParse(item['lon']?.toString() ?? '');
            if (lat != null && lon != null && lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
              results.add(
                GeocodingResult(
                  displayName: (item['display_name'] ?? '').toString(),
                  location: LatLng(lat, lon),
                ),
              );
            }
          }
        }
        _cache[normalizedKey] = _CachedGeocoding(DateTime.now(), results);
        return results;
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    
    return [];
  }
}
