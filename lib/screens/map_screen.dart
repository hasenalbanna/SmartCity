import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/sri_lanka_places.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  final String? placeName;
  final double? latitude;
  final double? longitude;

  const MapScreen({super.key, this.placeName, this.latitude, this.longitude});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = true;
  bool _showLiveLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );
    await locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _toggleLiveTracking() {
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );

    if (locationService.isTracking) {
      locationService.stopTracking();
    } else {
      locationService.startTracking();
    }

    setState(() => _showLiveLocation = !_showLiveLocation);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeLocation = widget.latitude != null && widget.longitude != null
        ? {'lat': widget.latitude!, 'lng': widget.longitude!}
        : widget.placeName != null
        ? LocationService.getLocationForPlace(widget.placeName!)
        : null;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0D12)
          : const Color(0xFFFFFBF0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12151C) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.placeName ?? 'Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        if (placeLocation != null)
                          Text(
                            '${placeLocation['lat']!.toStringAsFixed(4)}, ${placeLocation['lng']!.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showLiveLocation ? Icons.gps_fixed : Icons.gps_not_fixed,
                      color: _showLiveLocation
                          ? const Color(0xFF87CEEB)
                          : Colors.grey,
                    ),
                    onPressed: _toggleLiveTracking,
                  ),
                ],
              ),
            ),

            // Map Area (Placeholder - in production use google_maps_flutter)
            Expanded(
              child: Consumer<LocationService>(
                builder: (context, locationService, child) {
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF87CEEB),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      // Map Placeholder
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.shade100,
                              Colors.green.shade100,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Grid lines to simulate map
                            CustomPaint(
                              size: Size.infinite,
                              painter: _MapGridPainter(),
                            ),

                            // Place markers for all known destinations
                            ...sriLankaPlaces.map((place) {
                              final markerOffset = _placeToOffset(
                                size: MediaQuery.of(context).size,
                                lat: place.location.latitude,
                                lng: place.location.longitude,
                              );

                              return Positioned(
                                left: markerOffset.dx,
                                top: markerOffset.dy,
                                child: _buildMiniPlaceMarker(
                                  place.name,
                                  isDark,
                                ),
                              );
                            }),

                            // Center marker for destination
                            if (placeLocation != null)
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        widget.placeName ?? 'Destination',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 3,
                                      height: 20,
                                      color: const Color(0xFF87CEEB),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF87CEEB),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // User location marker
                            if (_showLiveLocation &&
                                locationService.currentPosition != null)
                              Positioned(
                                left: 100,
                                bottom: 150,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'You',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Distance Card
                      if (placeLocation != null)
                        Positioned(
                          bottom: 100,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF87CEEB,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.directions,
                                    color: Color(0xFF87CEEB),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.placeName ?? 'Destination',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        locationService.currentPosition != null
                                            ? 'Distance: ${locationService.formatDistance(locationService.getDistanceToPlace(widget.placeName ?? '') ?? 0)}'
                                            : 'Enable location to see distance',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Open in Google Maps
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Opening in Google Maps...',
                                        ),
                                        backgroundColor: Color(0xFF87CEEB),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.navigation, size: 18),
                                  label: const Text('Navigate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF87CEEB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Live Location Info
                      if (_showLiveLocation)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Live Tracking Enabled',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (locationService.currentPosition !=
                                          null)
                                        Text(
                                          'Lat: ${locationService.currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${locationService.currentPosition!.longitude.toStringAsFixed(4)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleLiveTracking,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12151C) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing location...')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF87CEEB),
                        side: const BorderSide(color: Color(0xFF87CEEB)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final locationService = Provider.of<LocationService>(
                          context,
                          listen: false,
                        );
                        locationService.getCurrentLocation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Getting your location...'),
                            backgroundColor: Color(0xFF87CEEB),
                          ),
                        );
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('My Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87CEEB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _placeToOffset({
    required Size size,
    required double lat,
    required double lng,
  }) {
    // Approximate Sri Lanka bounds for the placeholder map.
    const minLat = 5.9;
    const maxLat = 9.9;
    const minLng = 79.5;
    const maxLng = 81.9;

    final normalizedX = ((lng - minLng) / (maxLng - minLng)).clamp(0.0, 1.0);
    final normalizedY = (1 - (lat - minLat) / (maxLat - minLat)).clamp(
      0.0,
      1.0,
    );

    final mapWidth = size.width;
    final mapHeight =
        size.height -
        260; // Keep within map viewport, avoid header/footer overlap

    return Offset(
      normalizedX * (mapWidth - 64) + 20,
      normalizedY * (mapHeight - 64) + 20,
    );
  }

  Widget _buildMiniPlaceMarker(String name, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 84),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on_rounded,
            size: 10,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ],
    );
  }
}

// Custom painter for map grid
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw some "roads"
    final roadPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
