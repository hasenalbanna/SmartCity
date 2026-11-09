import 'package:latlong2/latlong.dart';

class CityLocation {
  final String name;
  final LatLng coordinates;

  const CityLocation({required this.name, required this.coordinates});
}

class CountryRegion {
  final String code;
  final String name;
  final String flag;
  final LatLng center;
  final double defaultZoom;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final List<CityLocation> cities;
  final List<LatLng> boundary;

  const CountryRegion({
    required this.code,
    required this.name,
    required this.flag,
    required this.center,
    this.defaultZoom = 12.0,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.cities,
    required this.boundary,
  });

  bool containsCoordinates(LatLng point) {
    return point.latitude >= minLat &&
        point.latitude <= maxLat &&
        point.longitude >= minLng &&
        point.longitude <= maxLng;
  }
}

class GlobalRegions {
  GlobalRegions._();

  static const List<CountryRegion> countries = [
    CountryRegion(
      code: 'LK',
      name: 'Sri Lanka',
      flag: '🇱🇰',
      center: LatLng(7.3486, 81.8494), // Defaults to Nintavur / East Hub
      defaultZoom: 13.5,
      minLat: 5.80,
      maxLat: 9.95,
      minLng: 79.50,
      maxLng: 82.05,
      cities: [
        CityLocation(name: 'Nintavur', coordinates: LatLng(7.3486, 81.8494)),
        CityLocation(name: 'Addappalam', coordinates: LatLng(7.3390, 81.8410)),
        CityLocation(name: 'Colombo', coordinates: LatLng(6.9271, 79.8612)),
        CityLocation(name: 'Kandy', coordinates: LatLng(7.2906, 80.6337)),
        CityLocation(name: 'Galle', coordinates: LatLng(6.0535, 80.2210)),
        CityLocation(name: 'Jaffna', coordinates: LatLng(9.6615, 80.0255)),
        CityLocation(name: 'Ella', coordinates: LatLng(6.8667, 81.0466)),
        CityLocation(name: 'Negombo', coordinates: LatLng(7.2008, 79.8736)),
        CityLocation(name: 'Trincomalee', coordinates: LatLng(8.5874, 81.2152)),
      ],
      boundary: [
        LatLng(9.83, 80.25),
        LatLng(9.50, 80.60),
        LatLng(8.55, 81.25),
        LatLng(7.35, 81.85),
        LatLng(6.00, 81.20),
        LatLng(5.92, 80.55),
        LatLng(6.92, 79.85),
        LatLng(8.00, 79.75),
        LatLng(9.00, 79.90),
        LatLng(9.83, 80.25),
      ],
    ),
    CountryRegion(
      code: 'GB',
      name: 'United Kingdom',
      flag: '🇬🇧',
      center: LatLng(51.5074, -0.1278),
      defaultZoom: 13.0,
      minLat: 49.80,
      maxLat: 60.90,
      minLng: -8.20,
      maxLng: 2.00,
      cities: [
        CityLocation(name: 'London', coordinates: LatLng(51.5074, -0.1278)),
        CityLocation(name: 'Manchester', coordinates: LatLng(53.4808, -2.2426)),
        CityLocation(name: 'Birmingham', coordinates: LatLng(52.4862, -1.8904)),
        CityLocation(name: 'Edinburgh', coordinates: LatLng(55.9533, -3.1883)),
        CityLocation(name: 'Glasgow', coordinates: LatLng(55.8642, -4.2518)),
      ],
      boundary: [
        LatLng(58.60, -3.00),
        LatLng(55.00, -1.40),
        LatLng(51.30, 1.40),
        LatLng(50.50, -1.00),
        LatLng(50.10, -5.70),
        LatLng(53.40, -4.50),
        LatLng(55.40, -4.80),
        LatLng(58.60, -5.00),
        LatLng(58.60, -3.00),
      ],
    ),
    CountryRegion(
      code: 'US',
      name: 'United States',
      flag: '🇺🇸',
      center: LatLng(40.7128, -74.0060),
      defaultZoom: 12.8,
      minLat: 24.50,
      maxLat: 49.50,
      minLng: -125.00,
      maxLng: -66.50,
      cities: [
        CityLocation(name: 'New York', coordinates: LatLng(40.7128, -74.0060)),
        CityLocation(name: 'Los Angeles', coordinates: LatLng(34.0522, -118.2437)),
        CityLocation(name: 'Chicago', coordinates: LatLng(41.8781, -87.6298)),
        CityLocation(name: 'San Francisco', coordinates: LatLng(37.7749, -122.4194)),
        CityLocation(name: 'Miami', coordinates: LatLng(25.7617, -80.1918)),
      ],
      boundary: [
        LatLng(49.00, -123.00),
        LatLng(49.00, -95.00),
        LatLng(45.00, -71.00),
        LatLng(41.00, -72.00),
        LatLng(25.00, -80.00),
        LatLng(26.00, -97.00),
        LatLng(32.00, -117.00),
        LatLng(48.00, -124.00),
        LatLng(49.00, -123.00),
      ],
    ),
    CountryRegion(
      code: 'AE',
      name: 'United Arab Emirates',
      flag: '🇦🇪',
      center: LatLng(25.2048, 55.2708),
      defaultZoom: 13.0,
      minLat: 22.50,
      maxLat: 26.20,
      minLng: 51.50,
      maxLng: 56.50,
      cities: [
        CityLocation(name: 'Dubai', coordinates: LatLng(25.2048, 55.2708)),
        CityLocation(name: 'Abu Dhabi', coordinates: LatLng(24.4539, 54.3773)),
        CityLocation(name: 'Sharjah', coordinates: LatLng(25.3463, 55.4209)),
        CityLocation(name: 'Ajman', coordinates: LatLng(25.4052, 55.5136)),
      ],
      boundary: [
        LatLng(26.00, 56.10),
        LatLng(25.00, 56.30),
        LatLng(24.00, 55.50),
        LatLng(23.00, 53.50),
        LatLng(24.00, 52.00),
        LatLng(25.00, 54.00),
        LatLng(25.50, 55.50),
        LatLng(26.00, 56.10),
      ],
    ),
    CountryRegion(
      code: 'JP',
      name: 'Japan',
      flag: '🇯🇵',
      center: LatLng(35.6762, 139.6503),
      defaultZoom: 13.0,
      minLat: 30.00,
      maxLat: 46.00,
      minLng: 128.50,
      maxLng: 146.00,
      cities: [
        CityLocation(name: 'Tokyo', coordinates: LatLng(35.6762, 139.6503)),
        CityLocation(name: 'Osaka', coordinates: LatLng(34.6937, 135.5023)),
        CityLocation(name: 'Kyoto', coordinates: LatLng(35.0116, 135.7681)),
        CityLocation(name: 'Yokohama', coordinates: LatLng(35.4437, 139.6380)),
      ],
      boundary: [
        LatLng(45.50, 141.90),
        LatLng(43.00, 145.80),
        LatLng(35.50, 140.50),
        LatLng(31.20, 130.50),
        LatLng(33.00, 129.50),
        LatLng(37.50, 137.00),
        LatLng(41.50, 140.00),
        LatLng(45.50, 141.90),
      ],
    ),
    CountryRegion(
      code: 'IN',
      name: 'India',
      flag: '🇮🇳',
      center: LatLng(19.0760, 72.8777),
      defaultZoom: 12.8,
      minLat: 8.00,
      maxLat: 37.00,
      minLng: 68.00,
      maxLng: 97.50,
      cities: [
        CityLocation(name: 'Mumbai', coordinates: LatLng(19.0760, 72.8777)),
        CityLocation(name: 'New Delhi', coordinates: LatLng(28.6139, 77.2090)),
        CityLocation(name: 'Bangalore', coordinates: LatLng(12.9716, 77.5946)),
        CityLocation(name: 'Chennai', coordinates: LatLng(13.0827, 80.2707)),
      ],
      boundary: [
        LatLng(35.50, 74.80),
        LatLng(31.00, 78.50),
        LatLng(27.00, 88.50),
        LatLng(26.00, 95.00),
        LatLng(22.00, 89.00),
        LatLng(12.00, 80.00),
        LatLng(8.10, 77.50),
        LatLng(15.00, 73.50),
        LatLng(23.50, 68.50),
        LatLng(35.50, 74.80),
      ],
    ),
    CountryRegion(
      code: 'FR',
      name: 'France',
      flag: '🇫🇷',
      center: LatLng(48.8566, 2.3522),
      defaultZoom: 13.0,
      minLat: 42.00,
      maxLat: 51.50,
      minLng: -5.00,
      maxLng: 9.50,
      cities: [
        CityLocation(name: 'Paris', coordinates: LatLng(48.8566, 2.3522)),
        CityLocation(name: 'Marseille', coordinates: LatLng(43.2965, 5.3698)),
        CityLocation(name: 'Lyon', coordinates: LatLng(45.7640, 4.8357)),
        CityLocation(name: 'Nice', coordinates: LatLng(43.7102, 7.2620)),
      ],
      boundary: [
        LatLng(51.00, 2.50),
        LatLng(49.00, 6.00),
        LatLng(45.80, 6.80),
        LatLng(43.60, 7.20),
        LatLng(42.50, 3.10),
        LatLng(43.40, -1.70),
        LatLng(47.30, -2.50),
        LatLng(48.50, -4.80),
        LatLng(51.00, 2.50),
      ],
    ),
    CountryRegion(
      code: 'AU',
      name: 'Australia',
      flag: '🇦🇺',
      center: LatLng(-33.8688, 151.2093),
      defaultZoom: 12.8,
      minLat: -44.00,
      maxLat: -10.00,
      minLng: 112.50,
      maxLng: 154.00,
      cities: [
        CityLocation(name: 'Sydney', coordinates: LatLng(-33.8688, 151.2093)),
        CityLocation(name: 'Melbourne', coordinates: LatLng(-37.8136, 144.9631)),
        CityLocation(name: 'Brisbane', coordinates: LatLng(-27.4698, 153.0251)),
        CityLocation(name: 'Perth', coordinates: LatLng(-31.9505, 115.8605)),
      ],
      boundary: [
        LatLng(-11.00, 142.50),
        LatLng(-24.50, 153.50),
        LatLng(-37.50, 150.00),
        LatLng(-39.00, 146.00),
        LatLng(-35.00, 117.00),
        LatLng(-22.00, 114.00),
        LatLng(-14.50, 129.00),
        LatLng(-11.00, 142.50),
      ],
    ),
    CountryRegion(
      code: 'SG',
      name: 'Singapore',
      flag: '🇸🇬',
      center: LatLng(1.3521, 103.8198),
      defaultZoom: 13.5,
      minLat: 1.15,
      maxLat: 1.48,
      minLng: 103.58,
      maxLng: 104.05,
      cities: [
        CityLocation(name: 'Downtown Core', coordinates: LatLng(1.2878, 103.8519)),
        CityLocation(name: 'Jurong East', coordinates: LatLng(1.3329, 103.7436)),
        CityLocation(name: 'Tampines', coordinates: LatLng(1.3533, 103.9452)),
        CityLocation(name: 'Woodlands', coordinates: LatLng(1.4382, 103.7890)),
      ],
      boundary: [
        LatLng(1.47, 103.75),
        LatLng(1.45, 103.90),
        LatLng(1.35, 104.05),
        LatLng(1.23, 103.85),
        LatLng(1.22, 103.65),
        LatLng(1.35, 103.60),
        LatLng(1.47, 103.75),
      ],
    ),
    CountryRegion(
      code: 'CA',
      name: 'Canada',
      flag: '🇨🇦',
      center: LatLng(43.6532, -79.3832),
      defaultZoom: 12.8,
      minLat: 41.50,
      maxLat: 70.00,
      minLng: -141.00,
      maxLng: -52.00,
      cities: [
        CityLocation(name: 'Toronto', coordinates: LatLng(43.6532, -79.3832)),
        CityLocation(name: 'Vancouver', coordinates: LatLng(49.2827, -123.1207)),
        CityLocation(name: 'Montreal', coordinates: LatLng(45.5017, -73.5673)),
        CityLocation(name: 'Calgary', coordinates: LatLng(51.0447, -114.0719)),
      ],
      boundary: [
        LatLng(69.00, -141.00),
        LatLng(69.00, -85.00),
        LatLng(52.00, -56.00),
        LatLng(44.00, -64.00),
        LatLng(42.00, -82.00),
        LatLng(49.00, -95.00),
        LatLng(49.00, -123.00),
        LatLng(54.00, -133.00),
        LatLng(60.00, -141.00),
        LatLng(69.00, -141.00),
      ],
    ),
  ];

  static CountryRegion get defaultCountry => countries.first; // Sri Lanka

  static CountryRegion findCountry(String query) {
    final q = query.trim().toLowerCase();
    return countries.firstWhere(
      (c) =>
          c.name.toLowerCase() == q ||
          c.code.toLowerCase() == q ||
          c.name.toLowerCase().contains(q),
      orElse: () => defaultCountry,
    );
  }

  static LatLng resolveLocation(String countryName, String cityName) {
    final country = findCountry(countryName);
    final cName = cityName.trim().toLowerCase();
    final matchedCity = country.cities.firstWhere(
      (c) =>
          c.name.toLowerCase() == cName ||
          c.name.toLowerCase().contains(cName) ||
          cName.contains(c.name.toLowerCase()),
      orElse: () => country.cities.first,
    );
    return matchedCity.coordinates;
  }

  static bool isWithinCountryBorder(String countryName, LatLng coordinates) {
    final country = findCountry(countryName);
    return country.containsCoordinates(coordinates);
  }
}

