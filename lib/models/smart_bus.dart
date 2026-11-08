import 'package:latlong2/latlong.dart';

enum BusOccupancy {
  low,
  moderate,
  crowded,
}

class BusStop {
  final String id;
  final String name;
  final LatLng location;

  const BusStop({
    required this.id,
    required this.name,
    required this.location,
  });
}

class BusRoute {
  final String id;
  final String routeNumber;
  final String origin;
  final String destination;
  final int colorHex;
  final List<BusStop> stops;
  final List<LatLng> pathPoints;
  final String operatingHours;
  final int frequencyMinutes;
  final double fareLkr;

  const BusRoute({
    required this.id,
    required this.routeNumber,
    required this.origin,
    required this.destination,
    required this.colorHex,
    required this.stops,
    required this.pathPoints,
    required this.operatingHours,
    required this.frequencyMinutes,
    required this.fareLkr,
  });

  String get displayName => '$routeNumber: $origin ⇄ $destination';
}

class SmartBus {
  final String id;
  final String routeId;
  final String busNumber;
  final String driverName;
  final LatLng location;
  final double speedKmH;
  final String nextStop;
  final int etaMinutes;
  final BusOccupancy occupancy;
  final bool isAirConditioned;
  final bool isWheelchairAccessible;
  final double bearing; // 0-360 degrees

  const SmartBus({
    required this.id,
    required this.routeId,
    required this.busNumber,
    required this.driverName,
    required this.location,
    required this.speedKmH,
    required this.nextStop,
    required this.etaMinutes,
    this.occupancy = BusOccupancy.moderate,
    this.isAirConditioned = true,
    this.isWheelchairAccessible = true,
    this.bearing = 0,
  });

  SmartBus copyWith({
    String? id,
    String? routeId,
    String? busNumber,
    String? driverName,
    LatLng? location,
    double? speedKmH,
    String? nextStop,
    int? etaMinutes,
    BusOccupancy? occupancy,
    bool? isAirConditioned,
    bool? isWheelchairAccessible,
    double? bearing,
  }) {
    return SmartBus(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      busNumber: busNumber ?? this.busNumber,
      driverName: driverName ?? this.driverName,
      location: location ?? this.location,
      speedKmH: speedKmH ?? this.speedKmH,
      nextStop: nextStop ?? this.nextStop,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      occupancy: occupancy ?? this.occupancy,
      isAirConditioned: isAirConditioned ?? this.isAirConditioned,
      isWheelchairAccessible: isWheelchairAccessible ?? this.isWheelchairAccessible,
      bearing: bearing ?? this.bearing,
    );
  }
}
