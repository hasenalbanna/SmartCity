import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  String? _errorMessage;

  // Sri Lanka famous locations
  static const Map<String, Map<String, double>> placeLocations = {
    'sigiriya': {'lat': 7.9570, 'lng': 80.7603},
    'kandy': {'lat': 7.2906, 'lng': 80.6337},
    'galle_fort': {'lat': 6.0328, 'lng': 80.2170},
    'galle': {'lat': 6.0328, 'lng': 80.2170},
    'ella': {'lat': 6.8762, 'lng': 81.0608},
    'mirissa': {'lat': 5.9485, 'lng': 80.4718},
    'yala': {'lat': 6.3728, 'lng': 81.5166},
    'colombo': {'lat': 6.9271, 'lng': 79.8612},
    'anuradhapura': {'lat': 8.3114, 'lng': 80.4037},
    'polonnaruwa': {'lat': 7.9403, 'lng': 81.0188},
    'dambulla': {'lat': 7.8675, 'lng': 80.6517},
    'nuwara_eliya': {'lat': 6.9497, 'lng': 80.7891},
    'trincomalee': {'lat': 8.5874, 'lng': 81.2152},
    'arugam_bay': {'lat': 6.8406, 'lng': 81.8367},
    'unawatuna': {'lat': 6.0090, 'lng': 80.2490},
    'bentota': {'lat': 6.4213, 'lng': 79.9976},
    'negombo': {'lat': 7.2094, 'lng': 79.8358},
    'jaffna': {'lat': 9.6615, 'lng': 80.0255},
    'adams_peak': {'lat': 6.8096, 'lng': 80.4994},
    'horton_plains': {'lat': 6.8019, 'lng': 80.8019},
  };

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  String? get errorMessage => _errorMessage;

  // Check and request location permissions
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage = 'Location services are disabled.';
      notifyListeners();
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = 'Location permissions are denied.';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorMessage = 'Location permissions are permanently denied.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    return true;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return null;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _errorMessage = 'Failed to get location: $e';
      notifyListeners();
      return null;
    }
  }

  // Start live tracking
  void startTracking() {
    if (_isTracking) return;

    _isTracking = true;
    notifyListeners();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Tracking error: $e';
        _isTracking = false;
        notifyListeners();
      },
    );
  }

  // Stop tracking
  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  // Get location for a place
  static Map<String, double>? getLocationForPlace(String placeName) {
    final key = placeName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
    return placeLocations[key];
  }

  // Calculate distance between two points
  double? getDistanceToPlace(String placeName) {
    if (_currentPosition == null) return null;

    final placeLocation = getLocationForPlace(placeName);
    if (placeLocation == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      placeLocation['lat']!,
      placeLocation['lng']!,
    );
  }

  // Format distance
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}
