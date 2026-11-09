import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/smart_bus.dart';
import 'global_destination_service.dart';

class SmartBusService extends ChangeNotifier {
  final List<BusRoute> _routes = [];
  final List<SmartBus> _buses = [];
  String? _selectedRouteId;
  Timer? _simulationTimer;
  final Map<String, int> _busWaypointIndices = {};

  List<BusRoute> get routes => List.unmodifiable(_routes);
  List<SmartBus> get buses => List.unmodifiable(_buses);
  String? get selectedRouteId => _selectedRouteId;

  BusRoute? get selectedRoute => _selectedRouteId == null
      ? null
      : _routes.firstWhere(
          (r) => r.id == _selectedRouteId,
          orElse: () => _routes.first,
        );

  String? _currentCountry;

  SmartBusService() {
    _initRoutesAndBuses();
    startLiveTracking();
  }

  void updateForCountry(String countryName, String cityName) {
    if (_currentCountry == countryName && _routes.isNotEmpty) return;
    _currentCountry = countryName;

    final transitData = GlobalDestinationService.getExperience(countryName).transitRoutes;
    if (transitData.isEmpty) return;

    _routes.clear();
    _buses.clear();
    _busWaypointIndices.clear();

    for (int rIdx = 0; rIdx < transitData.length; rIdx++) {
      final t = transitData[rIdx];
      final stops = <BusStop>[];
      for (int i = 0; i < t.stopNames.length; i++) {
        final pt = (i < t.pathPoints.length) ? t.pathPoints[i] : t.pathPoints.last;
        stops.add(BusStop(
          id: '${t.id}_stop_$i',
          name: t.stopNames[i],
          location: pt,
        ));
      }

      _routes.add(BusRoute(
        id: t.id,
        routeNumber: t.routeNumber,
        origin: t.origin,
        destination: t.destination,
        colorHex: t.colorHex,
        stops: stops,
        pathPoints: t.pathPoints,
        operatingHours: t.operatingHours,
        frequencyMinutes: t.frequencyMinutes,
        fareLkr: t.fareLocal,
      ));

      _buses.add(SmartBus(
        id: 'bus_${t.id}_1',
        routeId: t.id,
        busNumber: '${countryName.substring(0, min(2, countryName.length)).toUpperCase()}-${1000 + rIdx}',
        driverName: 'Transit Operator #${101 + rIdx}',
        location: t.pathPoints.first,
        speedKmH: 36.0,
        nextStop: t.stopNames.length > 1 ? t.stopNames[1] : t.stopNames.first,
        etaMinutes: 4,
        occupancy: BusOccupancy.moderate,
        isAirConditioned: true,
      ));
      _busWaypointIndices['bus_${t.id}_1'] = 0;
    }

    _selectedRouteId = _routes.first.id;
    notifyListeners();
  }

  void _initRoutesAndBuses() {
    // Route 1: Nintavur - Kalmunai Express
    const route1Stops = [
      BusStop(id: 's1', name: 'Nintavur Main Terminal', location: LatLng(7.3486, 81.8494)),
      BusStop(id: 's2', name: 'Hospital Junction', location: LatLng(7.3620, 81.8460)),
      BusStop(id: 's3', name: 'Addappalam Market', location: LatLng(7.3780, 81.8420)),
      BusStop(id: 's4', name: 'Sainthamaruthu Clock Tower', location: LatLng(7.3950, 81.8360)),
      BusStop(id: 's5', name: 'Kalmunai Central Bus Stand', location: LatLng(7.4167, 81.8333)),
    ];

    const route1Path = [
      LatLng(7.3486, 81.8494),
      LatLng(7.3550, 81.8480),
      LatLng(7.3620, 81.8460),
      LatLng(7.3700, 81.8440),
      LatLng(7.3780, 81.8420),
      LatLng(7.3870, 81.8390),
      LatLng(7.3950, 81.8360),
      LatLng(7.4050, 81.8345),
      LatLng(7.4167, 81.8333),
    ];

    // Route 2: Nintavur - Ampara City Connect
    const route2Stops = [
      BusStop(id: 's6', name: 'Nintavur Junction', location: LatLng(7.3486, 81.8494)),
      BusStop(id: 's7', name: 'Sammanthurai Town', location: LatLng(7.3690, 81.7980)),
      BusStop(id: 's8', name: 'Uhana Agricultural Zone', location: LatLng(7.3420, 81.7220)),
      BusStop(id: 's9', name: 'Ampara District Secretariat', location: LatLng(7.2912, 81.6747)),
    ];

    const route2Path = [
      LatLng(7.3486, 81.8494),
      LatLng(7.3580, 81.8250),
      LatLng(7.3690, 81.7980),
      LatLng(7.3550, 81.7580),
      LatLng(7.3420, 81.7220),
      LatLng(7.3150, 81.6980),
      LatLng(7.2912, 81.6747),
    ];

    _routes.addAll([
      const BusRoute(
        id: 'route_22',
        routeNumber: 'Route 22',
        origin: 'Nintavur',
        destination: 'Kalmunai',
        colorHex: 0xFF2563EB, // Royal Blue
        stops: route1Stops,
        pathPoints: route1Path,
        operatingHours: '05:30 AM - 10:00 PM',
        frequencyMinutes: 8,
        fareLkr: 85.0,
      ),
      const BusRoute(
        id: 'route_48',
        routeNumber: 'Route 48',
        origin: 'Nintavur',
        destination: 'Ampara',
        colorHex: 0xFF10B981, // Emerald Green
        stops: route2Stops,
        pathPoints: route2Path,
        operatingHours: '06:00 AM - 08:30 PM',
        frequencyMinutes: 15,
        fareLkr: 140.0,
      ),
    ]);

    // Active Smart Buses
    _buses.addAll([
      const SmartBus(
        id: 'bus_1',
        routeId: 'route_22',
        busNumber: 'NB-4482',
        driverName: 'R. Mohamed',
        location: LatLng(7.3620, 81.8460),
        speedKmH: 36.5,
        nextStop: 'Addappalam Market',
        etaMinutes: 3,
        occupancy: BusOccupancy.moderate,
        isAirConditioned: true,
        bearing: 340,
      ),
      const SmartBus(
        id: 'bus_2',
        routeId: 'route_22',
        busNumber: 'NC-1290',
        driverName: 'S. Nizar',
        location: LatLng(7.3950, 81.8360),
        speedKmH: 42.0,
        nextStop: 'Kalmunai Central Stand',
        etaMinutes: 6,
        occupancy: BusOccupancy.low,
        isAirConditioned: true,
        bearing: 345,
      ),
      const SmartBus(
        id: 'bus_3',
        routeId: 'route_48',
        busNumber: 'NA-8801',
        driverName: 'K. Bandara',
        location: LatLng(7.3550, 81.7580),
        speedKmH: 48.0,
        nextStop: 'Uhana Agricultural Zone',
        etaMinutes: 5,
        occupancy: BusOccupancy.crowded,
        isAirConditioned: false,
        bearing: 250,
      ),
    ]);

    _busWaypointIndices['bus_1'] = 2;
    _busWaypointIndices['bus_2'] = 6;
    _busWaypointIndices['bus_3'] = 3;
  }

  void startLiveTracking() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _advanceBusPositions();
    });
  }

  void stopLiveTracking() {
    _simulationTimer?.cancel();
  }

  void _advanceBusPositions() {
    for (int i = 0; i < _buses.length; i++) {
      final bus = _buses[i];
      final route = _routes.firstWhere(
        (r) => r.id == bus.routeId,
        orElse: () => _routes.first,
      );

      int currentIdx = _busWaypointIndices[bus.id] ?? 0;
      currentIdx = (currentIdx + 1) % route.pathPoints.length;
      _busWaypointIndices[bus.id] = currentIdx;

      final nextPos = route.pathPoints[currentIdx];
      final nextStop = route.stops[currentIdx % route.stops.length].name;
      final newEta = (bus.etaMinutes > 1) ? bus.etaMinutes - 1 : (route.frequencyMinutes ~/ 2);

      _buses[i] = bus.copyWith(
        location: nextPos,
        nextStop: nextStop,
        etaMinutes: newEta,
        speedKmH: 30.0 + (currentIdx * 3.5 % 20),
      );
    }
    notifyListeners();
  }

  void selectRoute(String? routeId) {
    _selectedRouteId = routeId;
    notifyListeners();
  }

  List<SmartBus> getBusesForSelectedRoute() {
    if (_selectedRouteId == null) return _buses;
    return _buses.where((b) => b.routeId == _selectedRouteId).toList();
  }

  BusRoute? getRouteById(String routeId) {
    for (final route in _routes) {
      if (route.id == routeId) return route;
    }
    return _routes.isNotEmpty ? _routes.first : null;
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

