import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class TripHistoryItem {
  final String id;
  final String fromLocation;
  final String toLocation;
  final String vehicle;
  final double distanceKm;
  final Duration timeTaken;
  final DateTime date;
  final String mapPreviewUrl;
  final double maxSpeedKmH;
  final String tripName;
  final double rating;

  TripHistoryItem({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    required this.vehicle,
    required this.distanceKm,
    required this.timeTaken,
    required this.date,
    required this.mapPreviewUrl,
    this.maxSpeedKmH = 0.0,
    this.tripName = 'My Trip',
    this.rating = 5.0,
  });
}

class TripHistoryService extends ChangeNotifier {
  final List<TripHistoryItem> _trips = [
    TripHistoryItem(
      id: const Uuid().v4(),
      fromLocation: 'Colombo',
      toLocation: 'Galle',
      vehicle: 'Car',
      distanceKm: 120.5,
      timeTaken: const Duration(hours: 2, minutes: 15),
      date: DateTime.now().subtract(const Duration(days: 2)),
      mapPreviewUrl: 'assets/southern province/galle fort.jpg',
    ),
    TripHistoryItem(
      id: const Uuid().v4(),
      fromLocation: 'Kandy',
      toLocation: 'Ella',
      vehicle: 'Train',
      distanceKm: 140.0,
      timeTaken: const Duration(hours: 6, minutes: 30),
      date: DateTime.now().subtract(const Duration(days: 10)),
      mapPreviewUrl: 'assets/images/nine_arch_bridge.jpg',
    ),
  ];

  List<TripHistoryItem> get trips => _trips;

  void addTrip(TripHistoryItem trip) {
    _trips.insert(0, trip);
    notifyListeners();
  }
}
