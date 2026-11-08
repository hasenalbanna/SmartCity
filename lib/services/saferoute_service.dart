import 'dart:math';
import 'package:latlong2/latlong.dart';

enum HazardType {
  accidentBlackspot,
  weatherHazard,
  disasterArea,
  highTraffic,
}

class Hazard {
  final String id;
  final String title;
  final String description;
  final HazardType type;
  final LatLng location;
  final double radiusKm;
  final int severity; // 1-10

  const Hazard({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.radiusKm,
    required this.severity,
  });
}

class SafetyScore {
  final int score; // 0-100
  final List<Hazard> encounteredHazards;
  final String summary;

  const SafetyScore({
    required this.score,
    required this.encounteredHazards,
    required this.summary,
  });
}

class SafeRouteService {
  // Mock hazard data around Sri Lanka
  static const List<Hazard> _hazards = [
    Hazard(
      id: 'h1',
      title: 'Accident Blackspot: Kadugannawa Pass',
      description: 'Historical high accident rate due to sharp bends and steep gradients. Drive with extreme caution.',
      type: HazardType.accidentBlackspot,
      location: LatLng(7.2625, 80.5217),
      radiusKm: 3.0,
      severity: 8,
    ),
    Hazard(
      id: 'h2',
      title: 'Weather Alert: Heavy Rain',
      description: 'Department of Meteorology reports intense localized showers. Risk of low visibility and slippery roads.',
      type: HazardType.weatherHazard,
      location: LatLng(6.9271, 79.8612), // Colombo area
      radiusKm: 15.0,
      severity: 6,
    ),
    Hazard(
      id: 'h3',
      title: 'Disaster Warning: Minor Landslide Risk',
      description: 'Recent heavy rains have weakened soil stability. Avoid if possible.',
      type: HazardType.disasterArea,
      location: LatLng(6.8667, 80.0474), // Ella area
      radiusKm: 5.0,
      severity: 7,
    ),
    Hazard(
      id: 'h4',
      title: 'Accident Blackspot: Galle Road Stretch',
      description: 'Frequent pedestrian accidents and high-speed collisions reported by Sri Lanka Police.',
      type: HazardType.accidentBlackspot,
      location: LatLng(6.4250, 79.9983),
      radiusKm: 8.0,
      severity: 9,
    ),
    Hazard(
      id: 'h5',
      title: 'Elephant Crossing Zone',
      description: 'Active wildlife crossing zone. High risk during dawn and dusk.',
      type: HazardType.accidentBlackspot,
      location: LatLng(6.3769, 81.3440), // Near Yala
      radiusKm: 10.0,
      severity: 7,
    ),
  ];

  List<Hazard> get allHazards => _hazards;

  // Haversine formula to calculate distance in km
  double _calculateDistance(LatLng p1, LatLng p2) {
    const double R = 6371; // Earth's radius in km
    final lat1 = p1.latitude * pi / 180;
    final lat2 = p2.latitude * pi / 180;
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLon = (p2.longitude - p1.longitude) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(lat1) * cos(lat2) *
              sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  /// Scores a route based on proximity to hazards
  SafetyScore scoreRoute(List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      return const SafetyScore(score: 100, encounteredHazards: [], summary: 'No route data available.');
    }

    Set<Hazard> encountered = {};
    int totalPenalty = 0;

    // Check each hazard against the route
    final step = max(1, routePoints.length ~/ 100);
    
    for (int i = 0; i < routePoints.length; i += step) {
      final point = routePoints[i];
      for (final hazard in _hazards) {
        if (encountered.contains(hazard)) continue;
        
        final dist = _calculateDistance(point, hazard.location);
        if (dist <= hazard.radiusKm) {
          encountered.add(hazard);
          totalPenalty += hazard.severity * 5; // Severity 1-10 -> 5-50 penalty points
        }
      }
    }

    int finalScore = 100 - totalPenalty;
    if (finalScore < 0) finalScore = 0;

    String summary;
    if (encountered.isEmpty) {
      summary = "AI analysis indicates a clear and highly safe route. No active hazards detected from police or meteorology data.";
    } else if (finalScore > 70) {
      summary = "SafeRoute AI identifies a relatively safe route, but advises caution near ${encountered.length} minor hazard zone(s).";
    } else if (finalScore > 40) {
      summary = "Moderate risks detected. The route passes through ${encountered.length} hazard area(s) including ${encountered.first.title}. Drive carefully.";
    } else {
      summary = "HIGH RISK WARNING! AI analysis strongly advises against this route. Multiple severe hazards detected.";
    }

    return SafetyScore(
      score: finalScore,
      encounteredHazards: encountered.toList(),
      summary: summary,
    );
  }
}
