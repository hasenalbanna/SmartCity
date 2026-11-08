import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/routing_service.dart';
import '../services/saferoute_service.dart';
import 'active_trip_screen.dart';

class DriveSetupScreen extends StatefulWidget {
  const DriveSetupScreen({super.key});

  @override
  State<DriveSetupScreen> createState() => _DriveSetupScreenState();
}

class _DriveSetupScreenState extends State<DriveSetupScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  
  final GeocodingService _geocodingService = GeocodingService();
  final RoutingService _routingService = RoutingService();

  String _selectedVehicle = 'Car';
  LatLng? _startLocation;
  LatLng? _endLocation;
  List<LatLng> _routePoints = [];
  SafetyScore? _safetyScore;
  bool _isLoadingRoute = false;
  
  final SafeRouteService _safeRouteService = SafeRouteService();
  
  final List<Map<String, dynamic>> _vehicles = [
    {'name': 'Car', 'icon': Icons.directions_car},
    {'name': 'Train', 'icon': Icons.directions_transit},
    {'name': 'Flight', 'icon': Icons.flight},
    {'name': 'Bus', 'icon': Icons.directions_bus},
    {'name': 'Lorry', 'icon': Icons.local_shipping},
  ];

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }
  
  Future<void> _initCurrentLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    if (locationService.currentPosition != null) {
      setState(() {
        _startLocation = LatLng(
          locationService.currentPosition!.latitude, 
          locationService.currentPosition!.longitude
        );
        _fromController.text = 'Current Location';
      });
    } else {
      // Fallback if permission not granted
      setState(() {
        _startLocation = const LatLng(6.9271, 79.8612); // Colombo
        _fromController.text = 'Colombo';
      });
    }
  }

  Future<void> _searchAndSelectDestination(BuildContext context, bool isFrom) async {
    final result = await showSearch<GeocodingResult?>(
      context: context,
      delegate: _PlaceSearchDelegate(_geocodingService),
    );
    
    if (result != null) {
      setState(() {
        if (isFrom) {
          _startLocation = result.location;
          _fromController.text = result.displayName;
        } else {
          _endLocation = result.location;
          _toController.text = result.displayName;
        }
      });
      
      _calculateRoute();
    }
  }
  
  Future<void> _calculateRoute() async {
    if (_startLocation != null && _endLocation != null) {
      setState(() => _isLoadingRoute = true);
      final result = await _routingService.getSafestRoute(_startLocation!, _endLocation!);
      setState(() {
        _routePoints = result.points;
        _safetyScore = result.safetyScore;
        _isLoadingRoute = false;
      });
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF2BC0E4);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drive Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Inputs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _searchAndSelectDestination(context, true),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _fromController,
                        decoration: InputDecoration(
                          labelText: 'From',
                          prefixIcon: Icon(Icons.my_location, color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _searchAndSelectDestination(context, false),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _toController,
                        decoration: InputDecoration(
                          labelText: 'To',
                          hintText: 'Search destination...',
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFFE5484D)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Vehicle Selection
            Text(
              'Select Vehicle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _vehicles[index];
                  final isSelected = _selectedVehicle == vehicle['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVehicle = vehicle['name'];
                      });
                    },
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? primaryColor : (isDark ? Colors.white24 : Colors.grey.shade300),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(vehicle['icon'], size: 36, color: isSelected ? primaryColor : (isDark ? Colors.white : Colors.black)),
                          const SizedBox(height: 8),
                          Text(
                            vehicle['name'],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? primaryColor : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            
            // Recent Destinations Quick-Select
            Text(
              'Recent Destinations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRecentChip('Colombo', const LatLng(6.9271, 79.8612)),
                  _buildRecentChip('Galle', const LatLng(6.0535, 80.2210)),
                  _buildRecentChip('Kandy', const LatLng(7.2906, 80.6337)),
                  _buildRecentChip('Ella', const LatLng(6.8667, 80.0474)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Real Map Preview
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: _startLocation ?? const LatLng(7.8731, 80.7718),
                        initialZoom: _routePoints.isNotEmpty ? 7.0 : 8.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.smartcity.app',
                        ),
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                color: const Color(0xFF2BC0E4),
                                strokeWidth: 4.0,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            ..._safeRouteService.allHazards.map((hazard) {
                              IconData iconData;
                              Color color;
                              if (hazard.type == HazardType.weatherHazard) {
                                iconData = Icons.thunderstorm;
                                color = Colors.blue;
                              } else if (hazard.type == HazardType.disasterArea) {
                                iconData = Icons.warning;
                                color = Colors.orange;
                              } else {
                                iconData = Icons.report;
                                color = Colors.red;
                              }
                              return Marker(
                                point: hazard.location,
                                width: 30,
                                height: 30,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
                                  ),
                                  child: Icon(iconData, color: color, size: 18),
                                ),
                              );
                            }),
                            if (_startLocation != null)
                              Marker(
                                point: _startLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on, color: Color(0xFFE5484D), size: 30),
                              ),
                            if (_endLocation != null)
                              Marker(
                                point: _endLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.flag, color: Colors.green, size: 30),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (_isLoadingRoute)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFF2BC0E4)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            if (_safetyScore != null) _buildSafetyScorePanel(isDark),
            const SizedBox(height: 24),
            
            // Start Trip Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_endLocation == null || _startLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select both From and To locations')),
                    );
                    return;
                  }
                  
                  if (_routePoints.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route is still calculating...')),
                    );
                    return;
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveTripScreen(
                        destinationName: _toController.text,
                        vehicle: _selectedVehicle,
                        routePoints: _routePoints,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Start Trip',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChip(String name, LatLng location) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(name),
        avatar: const Icon(Icons.history, size: 16),
        onPressed: () {
          setState(() {
            _endLocation = location;
            _toController.text = name;
          });
          _calculateRoute();
        },
      ),
    );
  }
  
  Widget _buildSafetyScorePanel(bool isDark) {
    final score = _safetyScore!.score;
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.redAccent;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: scoreColor, size: 28),
              const SizedBox(width: 8),
              Text(
                'SafeRoute AI Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                '$score/100',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _safetyScore!.summary,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          if (_safetyScore!.encounteredHazards.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Hazards on Route:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 6),
            ..._safetyScore!.encounteredHazards.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      h.title,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _PlaceSearchDelegate extends SearchDelegate<GeocodingResult?> {
  final GeocodingService service;
  
  _PlaceSearchDelegate(this.service);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return const SizedBox();
    return _buildSearchResults();
  }
  
  Widget _buildSearchResults() {
    return FutureBuilder<List<GeocodingResult>>(
      future: service.searchPlaces(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No places found.'));
        }
        
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final place = snapshot.data![index];
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(place.displayName),
              onTap: () {
                close(context, place);
              },
            );
          },
        );
      },
    );
  }
}
