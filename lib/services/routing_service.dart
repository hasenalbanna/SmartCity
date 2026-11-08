import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'saferoute_service.dart';

class RouteResult {
  final List<LatLng> points;
  final SafetyScore safetyScore;

  const RouteResult({required this.points, required this.safetyScore});
}

class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving/';

  bool _isValidCoordinate(LatLng point) {
    return point.latitude.isFinite &&
        point.longitude.isFinite &&
        point.latitude >= -90.0 &&
        point.latitude <= 90.0 &&
        point.longitude >= -180.0 &&
        point.longitude <= 180.0;
  }

  /// Fetches a route between two coordinates
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final result = await getSafestRoute(start, end);
    return result.points;
  }

  /// Fetches multiple routes, scores them, and returns the safest one
  Future<RouteResult> getSafestRoute(LatLng start, LatLng end) async {
    if (!_isValidCoordinate(start) || !_isValidCoordinate(end)) {
      return const RouteResult(
        points: [],
        safetyScore: SafetyScore(score: 0, encounteredHazards: [], summary: 'Invalid coordinate bounds'),
      );
    }

    final url = '$_baseUrl${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&alternatives=3';
    
    final safeRouteService = SafeRouteService();
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'SmartCity/1.0 (https://smartcity.local)'},
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        
        if (routes.isNotEmpty) {
          List<LatLng> bestRoute = [];
          SafetyScore bestScore = const SafetyScore(score: -1, encounteredHazards: [], summary: '');

          for (final route in routes) {
            final geometry = route['geometry']['coordinates'] as List;
            final points = geometry.map((coord) => LatLng(coord[1], coord[0])).toList();
            
            final score = safeRouteService.scoreRoute(points);
            if (score.score > bestScore.score) {
              bestScore = score;
              bestRoute = points;
            }
          }
          
          return RouteResult(points: bestRoute, safetyScore: bestScore);
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
    
    return RouteResult(
      points: [], 
      safetyScore: const SafetyScore(score: 0, encounteredHazards: [], summary: 'Failed to fetch route'),
    );
  }
}
